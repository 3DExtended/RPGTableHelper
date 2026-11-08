import type { NextFunction, Request, Response } from 'express';
import { log } from '../log.js';
import type { TokenStore } from './tokenStore.js';

/**
 * Lets a request through only with a valid access token. Anything else gets 401 with the address of the
 * protected resource metadata, which is what makes Claude start the login.
 */
export function requireBearer(tokens: TokenStore, resourceMetadataUrl: string) {
  return (req: Request, res: Response, next: NextFunction) => {
    const header = req.headers.authorization ?? '';
    const match = /^Bearer\s+([A-Za-z0-9._~+/=-]+)$/i.exec(header);
    const challenge = [`Bearer resource_metadata="${resourceMetadataUrl}"`];
    if (match?.[1]) {
      const session = tokens.validateAccess(match[1]);
      if (session) {
        res.locals.session = session;
        next();
        return;
      }
      challenge.push('error="invalid_token"', 'error_description="The access token is invalid or expired"');
      log.info('auth.invalid_token');
    }
    res
      .status(401)
      .set('WWW-Authenticate', challenge.join(', '))
      .json({ error: 'unauthorized', error_description: 'Sign in to use this server.' });
  };
}
