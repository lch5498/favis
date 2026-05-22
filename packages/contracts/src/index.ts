import { z } from 'zod';

const isoDateTime = z.string().datetime({ offset: true });

export const academyEventSchema = z.object({
  id: z.string().uuid(),
  student_name: z.string().min(1),
  title: z.string().min(1),
  starts_at: isoDateTime,
  ends_at: isoDateTime.nullable(),
  memo: z.string().nullable(),
  created_at: isoDateTime,
  updated_at: isoDateTime,
});

export const createAcademyEventSchema = academyEventSchema
  .pick({
    student_name: true,
    title: true,
    starts_at: true,
    ends_at: true,
    memo: true,
  })
  .extend({
    ends_at: isoDateTime.nullable().optional(),
    memo: z.string().nullable().optional(),
  });

export const parkingRecordSchema = z.object({
  id: z.string().uuid(),
  car_label: z.string().min(1),
  location_label: z.string().min(1),
  parked_at: isoDateTime,
  memo: z.string().nullable(),
  photo_url: z.string().url().nullable(),
  is_active: z.boolean(),
  created_at: isoDateTime,
  updated_at: isoDateTime,
});

export const createParkingRecordSchema = parkingRecordSchema
  .pick({
    car_label: true,
    location_label: true,
    parked_at: true,
    memo: true,
    photo_url: true,
  })
  .extend({
    memo: z.string().nullable().optional(),
    photo_url: z.string().url().nullable().optional(),
  });

export type AcademyEvent = z.infer<typeof academyEventSchema>;
export type CreateAcademyEvent = z.infer<typeof createAcademyEventSchema>;
export type ParkingRecord = z.infer<typeof parkingRecordSchema>;
export type CreateParkingRecord = z.infer<typeof createParkingRecordSchema>;
