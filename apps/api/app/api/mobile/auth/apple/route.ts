import { verifyAppleIdentityToken } from '../../../../../src/apple';
import { jsonFromError } from '../../../../../src/http';
import {
  createSessionToken,
  getSessionTtlSeconds,
} from '../../../../../src/session';
import { findOrCreateUserFromApple } from '../../../../../src/users';
import {
  optionalString,
  readJsonObject,
  requiredString,
} from '../../../../../src/validation';

export const runtime = 'nodejs';

export async function POST(request: Request) {
  try {
    const payload = await readJsonObject(request);
    const identityToken = requiredString(payload, 'identityToken');
    const nickname = optionalString(payload, 'nickname', { maxLength: 30 });
    const appleUser = await verifyAppleIdentityToken(identityToken);
    const loginResult = await findOrCreateUserFromApple(appleUser, {
      nickname,
    });

    if (loginResult.requiresProfile) {
      return Response.json(
        {
          error: 'profile_required',
          provider: loginResult.provider,
          providerId: loginResult.providerId,
        },
        { status: 409 },
      );
    }

    const user = loginResult.user;
    const sessionToken = createSessionToken(user.id);

    return Response.json({
      tokenType: 'Bearer',
      accessToken: sessionToken,
      expiresIn: getSessionTtlSeconds(),
      isNewUser: loginResult.isNewUser,
      user,
    });
  } catch (error) {
    return jsonFromError(error, 'login_failed');
  }
}
