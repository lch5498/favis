export function GET() {
  return Response.json({
    ok: true,
    service: 'favis-api',
    framework: 'nextjs',
  });
}
