export function GET() {
  return Response.json({
    ok: true,
    service: 'family-housekeeping-api',
    framework: 'nextjs',
  });
}
