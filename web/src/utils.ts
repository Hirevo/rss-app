export function percentEncode(path: string): string {
    return path.split("/").map(encodeURIComponent).join("/").replace(/'/g, "%27").replace(/\(/g, "%28").replace(/\)/g, "%29");
}
