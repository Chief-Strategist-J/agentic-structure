/**
 * Generic functional combinators for pipelines.
 */
export const pipe = <T, R = unknown>(
  initial: T,
  ...fns: Array<(arg: unknown) => unknown>
): R => fns.reduce((acc, fn) => fn(acc), initial as unknown) as R;

export const flow =
  <T extends readonly unknown[], R>(
    fn1: (...args: T) => unknown,
    ...fns: Array<(arg: unknown) => unknown>
  ) =>
  (...args: T): R =>
    fns.reduce((acc, fn) => fn(acc), fn1(...args)) as R;

export const partition = <T>(
  arr: readonly T[],
  predicate: (item: T) => boolean
): [T[], T[]] => {
  const matching: T[] = [];
  const nonMatching: T[] = [];
  arr.forEach((item) => {
    if (predicate(item)) {
      matching.push(item);
    } else {
      nonMatching.push(item);
    }
  });
  return [matching, nonMatching];
};

export const chunk = <T>(arr: readonly T[], size: number): T[][] => {
  if (size <= 0) return [[]];
  const chunks: T[][] = [];
  for (let i = 0; i < arr.length; i += size) {
    chunks.push(arr.slice(i, i + size));
  }
  return chunks;
};
