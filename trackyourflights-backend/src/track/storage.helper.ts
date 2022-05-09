import { promises as fs, existsSync } from 'fs';
import * as p from "path"

/**
 * Check if a file exists at a given path.
 *
 * @param {string} path
 *
 * @returns {boolean}
 */
export const checkIfFileOrDirectoryExists = (path: string): boolean => {
  return existsSync(path);
};

/**
 * Writes a file at a given path via a promise interface.
 *
 * @param {string} path
 * @param {string} data
 *
 * @return {Promise<void>}
 */
export const writeFile = async (
  path: string,
  data: string,
): Promise<void> => {
  if (!checkIfFileOrDirectoryExists(path)) {
    await fs.mkdir(p.dirname(path), { recursive: true });
  }


  return await fs.writeFile(path, data, {encoding: 'utf8', });
};
