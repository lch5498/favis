import { z } from 'zod';

import { getKakaoUser } from '../../../../../src/kakao';
import {
  createSessionToken,
  getSessionTtlSeconds,
} from '../../../../../src/session';
import { findOrCreateUserFromKakao } from '../../../../../src/users';

export const runtime = 'nodejs';

const kakaoLoginRequestSchema = z.object({
  accessToken: z.string().min(1),
});

export async function POST(request: Request) {
  try {
    const payload = kakaoLoginRequestSchema.parse(await request.json());
    const kakaoUser = await getKakaoUser(payload.accessToken);
    const user = await findOrCreateUserFromKakao(kakaoUser);
    const sessionToken = createSessionToken(user.id);

    return Response.json({
      tokenType: 'Bearer',
      accessToken: sessionToken,
      expiresIn: getSessionTtlSeconds(),
      user,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return Response.json(
        { error: 'invalid_payload', issues: error.issues },
        { status: 400 },
      );
    }

    console.error(error);
    return Response.json({ error: 'login_failed' }, { status: 401 });
  }
}
