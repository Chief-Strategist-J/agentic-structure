import { describe, it, expect } from 'vitest';
import { formatDateISO } from '../../../packages/shared/lib/formatters/date';

describe('Date Formatter Utility', () => {
  it('should format date string to ISO date', () => {
    const res = formatDateISO('2026-08-19T12:00:00Z');
    expect(res).toBe('2026-08-19');
  });
});
