import { Request, Response, NextFunction } from 'express';
import { expressjwt as jwt } from 'express-jwt';
import jwksRsa from 'jwks-rsa';

export interface AuthenticatedUser {
  sub: string;
  tenant_id: string;
  role: 'owner' | 'admin' | 'editor' | 'viewer';
  allowed_tenants: string[];
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
    }
  }
}

const AUTH0_DOMAIN = process.env.AUTH0_DOMAIN || 'auth0.auth0.com';
const AUTH0_AUDIENCE = process.env.AUTH0_AUDIENCE || 'https://api.connecthub.io';
const CLAIM_NS = 'https://connecthub.io/claims';

export const checkJwt = jwt({
  secret: jwksRsa.expressJwtSecret({
    cache: true,
    rateLimit: true,
    jwksRequestsPerMinute: 10,
    jwksUri: `https://${AUTH0_DOMAIN}/.well-known/jwks.json`
  }) as any,
  audience: AUTH0_AUDIENCE,
  issuer: `https://${AUTH0_DOMAIN}/`,
  algorithms: ['RS256']
});

export const resolveTenantContext = (req: Request, res: Response, next: NextFunction) => {
  const tokenPayload = (req as any).auth;
  if (!tokenPayload) {
    return res.status(401).json({ error: 'Unauthorized: Missing or invalid token' });
  }

  // 1. Resolve permitted tenants directly from cryptographically signed claims
  const primaryTenant = tokenPayload[`${CLAIM_NS}/tenant_id`] || tokenPayload.org_id;
  const allowedTenants: string[] = tokenPayload[`${CLAIM_NS}/allowed_tenants`] ||
    (tokenPayload.org_id ? [tokenPayload.org_id] : (primaryTenant ? [primaryTenant] : []));

  // 2. Reject if no verified tenant claims exist in the token
  if (!primaryTenant && allowedTenants.length === 0) {
    return res.status(403).json({
      error: 'Forbidden: Token contains no verified tenant claims. Access denied.'
    });
  }

  // 3. Strictly validate any client-requested tenant against the allowed list (anti-spoofing)
  const requestedTenant = req.headers['x-tenant-id'] as string | undefined;
  let activeTenant = primaryTenant || allowedTenants[0];

  if (requestedTenant) {
    if (!allowedTenants.includes(requestedTenant)) {
      return res.status(403).json({
        error: `Forbidden: Tenant '${requestedTenant}' is not authorized for this identity. Cross-tenant access blocked.`
      });
    }
    activeTenant = requestedTenant;
  }

  req.user = {
    sub: tokenPayload.sub,
    tenant_id: activeTenant,
    role: tokenPayload[`${CLAIM_NS}/role`] || 'viewer',
    allowed_tenants: allowedTenants
  };

  next();
};

export const requireRole = (allowedRoles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden: Insufficient tenant permissions' });
    }
    next();
  };
};
