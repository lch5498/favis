import { requireFamilyManager, requireMembership } from './families';
import { HttpError } from './http';
import { getSupabaseAdmin } from './supabase';

export type ParkingPresetType = 'floor' | 'spot';

export type Vehicle = {
  id: string;
  family_id: string;
  nickname: string;
  plate_number: string;
  created_at: string;
  updated_at: string;
};

export type ParkingLocationPreset = {
  id: string;
  family_id: string;
  preset_type: ParkingPresetType;
  name: string;
  sort_order: number;
  created_at: string;
  updated_at: string;
};

export type ParkingRecord = {
  id: string;
  family_id: string;
  vehicle_id: string;
  floor_preset_id: string | null;
  spot_preset_id: string | null;
  floor_text: string;
  spot_text: string;
  location_text: string;
  created_by_user_id: string | null;
  parked_at: string;
  created_at: string;
  updated_at: string;
  created_by_user?: {
    id: string;
    nickname: string;
  } | null;
};

export async function getParkingDashboard(userId: string, familyId: string) {
  const membership = await requireMembership(userId, familyId);
  const [vehicles, presets] = await Promise.all([
    listVehicles(userId, familyId),
    listParkingLocationPresets(userId, familyId),
  ]);
  const currentLocations = await listCurrentParkingRecords(familyId);

  return {
    canManage: membership.role === 'owner' || membership.role === 'co_owner',
    vehicles,
    presets,
    currentLocations,
  };
}

export async function listVehicles(userId: string, familyId: string) {
  await requireMembership(userId, familyId);

  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from('vehicles')
    .select('*')
    .eq('family_id', familyId)
    .order('created_at', { ascending: true });

  if (error) {
    throw error;
  }

  return (data ?? []) as Vehicle[];
}

export async function createVehicle(
  userId: string,
  familyId: string,
  input: { nickname: string; plateNumber: string },
) {
  await requireFamilyManager(userId, familyId);

  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from('vehicles')
    .insert({
      family_id: familyId,
      nickname: normalizeText(input.nickname, 'nickname', 30),
      plate_number: normalizeText(input.plateNumber, 'plate_number', 30),
    })
    .select('*')
    .single();

  if (error) {
    throw error;
  }

  return data as Vehicle;
}

export async function updateVehicle(
  userId: string,
  familyId: string,
  vehicleId: string,
  input: { nickname: string; plateNumber: string },
) {
  await requireFamilyManager(userId, familyId);

  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from('vehicles')
    .update({
      nickname: normalizeText(input.nickname, 'nickname', 30),
      plate_number: normalizeText(input.plateNumber, 'plate_number', 30),
    })
    .eq('id', vehicleId)
    .eq('family_id', familyId)
    .select('*')
    .maybeSingle();

  if (error) {
    throw error;
  }

  if (!data) {
    throw new HttpError(404, { error: 'vehicle_not_found' });
  }

  return data as Vehicle;
}

export async function deleteVehicle(
  userId: string,
  familyId: string,
  vehicleId: string,
) {
  await requireFamilyManager(userId, familyId);

  const supabase = getSupabaseAdmin();
  const { error } = await supabase
    .from('vehicles')
    .delete()
    .eq('id', vehicleId)
    .eq('family_id', familyId);

  if (error) {
    throw error;
  }
}

export async function listParkingLocationPresets(
  userId: string,
  familyId: string,
) {
  await requireMembership(userId, familyId);

  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from('parking_location_presets')
    .select('*')
    .eq('family_id', familyId)
    .order('sort_order', { ascending: true })
    .order('created_at', { ascending: true });

  if (error) {
    throw error;
  }

  return (data ?? []) as ParkingLocationPreset[];
}

export async function createParkingLocationPreset(
  userId: string,
  familyId: string,
  input: { presetType: string; name: string },
) {
  await requireFamilyManager(userId, familyId);

  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from('parking_location_presets')
    .insert({
      family_id: familyId,
      preset_type: normalizePresetType(input.presetType),
      name: normalizeText(input.name, 'name', 40),
    })
    .select('*')
    .single();

  if (error) {
    throw error;
  }

  return data as ParkingLocationPreset;
}

export async function updateParkingLocationPreset(
  userId: string,
  familyId: string,
  presetId: string,
  input: { presetType: string; name: string },
) {
  await requireFamilyManager(userId, familyId);

  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from('parking_location_presets')
    .update({
      preset_type: normalizePresetType(input.presetType),
      name: normalizeText(input.name, 'name', 40),
    })
    .eq('id', presetId)
    .eq('family_id', familyId)
    .select('*')
    .maybeSingle();

  if (error) {
    throw error;
  }

  if (!data) {
    throw new HttpError(404, { error: 'parking_location_preset_not_found' });
  }

  return data as ParkingLocationPreset;
}

export async function deleteParkingLocationPreset(
  userId: string,
  familyId: string,
  presetId: string,
) {
  await requireFamilyManager(userId, familyId);

  const supabase = getSupabaseAdmin();
  const { error } = await supabase
    .from('parking_location_presets')
    .delete()
    .eq('id', presetId)
    .eq('family_id', familyId);

  if (error) {
    throw error;
  }
}

export async function createParkingRecord(
  userId: string,
  familyId: string,
  input: {
    vehicleId: string;
    floorPresetId?: string;
    spotPresetId?: string;
    floorText: string;
    spotText: string;
  },
) {
  await requireFamilyManager(userId, familyId);

  const vehicle = await getVehicleOrThrow(familyId, input.vehicleId);
  const floorPresetId = await normalizePresetId(
    familyId,
    input.floorPresetId,
    'floor',
  );
  const spotPresetId = await normalizePresetId(
    familyId,
    input.spotPresetId,
    'spot',
  );
  const floorText = normalizeText(input.floorText, 'floorText', 40);
  const spotText = normalizeText(input.spotText, 'spotText', 40);

  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from('parking_records')
    .insert({
      family_id: familyId,
      vehicle_id: vehicle.id,
      floor_preset_id: floorPresetId,
      spot_preset_id: spotPresetId,
      floor_text: floorText,
      spot_text: spotText,
      location_text: `${floorText} / ${spotText}`,
      created_by_user_id: userId,
    })
    .select(parkingRecordSelect)
    .single();

  if (error) {
    throw error;
  }

  return data as ParkingRecord;
}

async function listCurrentParkingRecords(familyId: string) {
  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from('parking_records')
    .select(parkingRecordSelect)
    .eq('family_id', familyId)
    .order('parked_at', { ascending: false });

  if (error) {
    throw error;
  }

  const records = new Map<string, ParkingRecord>();

  for (const record of (data ?? []) as ParkingRecord[]) {
    if (!records.has(record.vehicle_id)) {
      records.set(record.vehicle_id, record);
    }
  }

  return Array.from(records.values());
}

async function getVehicleOrThrow(familyId: string, vehicleId: string) {
  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from('vehicles')
    .select('*')
    .eq('id', vehicleId)
    .eq('family_id', familyId)
    .maybeSingle();

  if (error) {
    throw error;
  }

  if (!data) {
    throw new HttpError(404, { error: 'vehicle_not_found' });
  }

  return data as Vehicle;
}

async function getPresetOrThrow(familyId: string, presetId: string) {
  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase
    .from('parking_location_presets')
    .select('*')
    .eq('id', presetId)
    .eq('family_id', familyId)
    .maybeSingle();

  if (error) {
    throw error;
  }

  if (!data) {
    throw new HttpError(404, { error: 'parking_location_preset_not_found' });
  }

  return data as ParkingLocationPreset;
}

async function normalizePresetId(
  familyId: string,
  presetId: string | undefined,
  presetType: ParkingPresetType,
) {
  const normalized = presetId?.trim() || null;

  if (!normalized) {
    return null;
  }

  const preset = await getPresetOrThrow(familyId, normalized);

  if (preset.preset_type !== presetType) {
    throw new HttpError(400, {
      error: 'parking_preset_type_mismatch',
      field: presetType === 'floor' ? 'floorPresetId' : 'spotPresetId',
    });
  }

  return preset.id;
}

function normalizePresetType(value: string): ParkingPresetType {
  if (value === 'floor' || value === 'spot') {
    return value;
  }

  throw new HttpError(400, { error: 'invalid_payload', field: 'presetType' });
}

const parkingRecordSelect = `
  *,
  created_by_user:users (
    id,
    nickname
  )
`;

function normalizeText(value: string, field: string, maxLength: number) {
  const normalized = value.trim();

  if (!normalized) {
    throw new HttpError(400, { error: 'invalid_payload', field });
  }

  if (normalized.length > maxLength) {
    throw new HttpError(400, { error: 'invalid_payload', field });
  }

  return normalized;
}
