export function getIdentFromHistoryLink(historyLink: string) {
  const match = historyLink.match(/\/live\/flight\/([\da-zA-Z]+)\/?/g);
  if (match == null) return ''
  const pathPart = match[1] ?? '';
  return pathPart;
}

export function getPathFromHistoryLink(historyLink: string) {
  const matches = historyLink.matchAll(/\/live\/flight\/[\da-zA-Z]+\/history\/[\d]+\/[\d]+Z([\/0-9a-zA-Z]+)/g);
  const match = matches.next().value
  if (match == null) return null
  const pathPart: string = match[1] ?? '';
  if (pathPart) {
    const res = pathPart.split('/')
    return {
      origin: res[1],
      dest: res[2]
    }
  }
  return null;
}