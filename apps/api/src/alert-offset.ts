import { HttpError } from './http';

export const MAX_ALERT_OFFSET_MINUTES = 60 * 24 * 365;

export function normalizeAlertOffsetMinutes(
  value: number | null | undefined,
  field = 'alertOffsetMinutes',
) {
  if (value === undefined || value === null) {
    return null;
  }

  if (
    !Number.isInteger(value) ||
    value < 0 ||
    value > MAX_ALERT_OFFSET_MINUTES
  ) {
    throw new HttpError(400, { error: 'invalid_payload', field });
  }

  return value;
}
