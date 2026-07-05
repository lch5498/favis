import { timingSafeEqual } from 'node:crypto';

import { sendFcmNotification } from '../../../../src/fcm';
import { HttpError, jsonFromError } from '../../../../src/http';
import { authenticateMobileRequest } from '../../../../src/mobile-auth';
import {
  listAllPushTokens,
  listPushTokensForUser,
  type PushTokenRecord,
} from '../../../../src/push-tokens';
import { getBearerToken } from '../../../../src/session';
import { optionalString, readJsonObject } from '../../../../src/validation';

export const runtime = 'nodejs';

type PushTarget = PushTokenRecord | {
  id: string;
  token: string;
  platform: 'direct';
};

export async function POST(request: Request) {
  try {
    const payload = await readJsonObject(request);
    const title =
      optionalString(payload, 'title', { maxLength: 80 }) ?? '체키 테스트 알림';
    const body =
      optionalString(payload, 'body', { maxLength: 200 }) ??
      '푸시 알림 연결이 정상입니다.';
    const validateOnly = payload.validateOnly === true;
    const isAdmin = isAdminRequest(request);
    const tokens = isAdmin
      ? await resolveAdminTargets(payload)
      : await resolveUserTargets(request);

    if (tokens.length === 0) {
      throw new HttpError(404, { error: 'no_push_tokens' });
    }

    const results = await Promise.all(
      tokens.map(async (pushToken) => {
        const result = await sendFcmNotification({
          token: pushToken.token,
          title,
          body,
          validateOnly,
          data: {
            type: 'push_test',
          },
        });

        return {
          id: pushToken.id,
          platform: pushToken.platform,
          userId: 'userId' in pushToken ? pushToken.userId : undefined,
          ...result,
        };
      }),
    );

    const successCount = results.filter((result) => result.ok).length;
    const failureCount = results.length - successCount;

    return Response.json(
      {
        ok: successCount > 0,
        authMode: isAdmin ? 'admin' : 'user',
        validateOnly,
        tokenCount: tokens.length,
        successCount,
        failureCount,
        results,
      },
      { status: successCount > 0 ? 200 : 502 },
    );
  } catch (error) {
    return jsonFromError(error, 'push_test_failed');
  }
}

async function resolveUserTargets(request: Request) {
  const userId = authenticateMobileRequest(request);
  return listPushTokensForUser(userId);
}

async function resolveAdminTargets(payload: Record<string, unknown>) {
  const token = optionalString(payload, 'token', { maxLength: 4096 });
  const userId = optionalString(payload, 'userId', { maxLength: 64 });
  const sendAll = payload.all === true;
  const targetCount = Number(Boolean(token)) + Number(Boolean(userId)) + Number(sendAll);

  if (targetCount !== 1) {
    throw new HttpError(400, {
      error: 'invalid_push_test_target',
      message: 'Set exactly one of token, userId, or all=true.',
    });
  }

  if (token) {
    return [{ id: 'direct', token, platform: 'direct' }] satisfies PushTarget[];
  }

  if (userId) {
    return listPushTokensForUser(userId);
  }

  return listAllPushTokens();
}

function isAdminRequest(request: Request) {
  const bearerToken = getBearerToken(request);
  const adminKey = process.env.PUSH_TEST_ADMIN_KEY?.trim();

  if (!bearerToken || !adminKey) {
    return false;
  }

  const bearerTokenBuffer = Buffer.from(bearerToken);
  const adminKeyBuffer = Buffer.from(adminKey);

  if (bearerTokenBuffer.length !== adminKeyBuffer.length) {
    return false;
  }

  return timingSafeEqual(bearerTokenBuffer, adminKeyBuffer);
}
