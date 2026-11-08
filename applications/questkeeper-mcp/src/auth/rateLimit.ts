/**
 * Counts failed logins: per address and for everyone together. A locked address (or a locked server, when
 * someone tries from many addresses) is refused before the password is even checked.
 */
export class LoginThrottle {
  private readonly perAddress = new Map<string, number[]>();
  private global: number[] = [];

  constructor(
    private readonly options = {
      perAddressLimit: 5,
      perAddressWindowMs: 15 * 60_000,
      globalLimit: 20,
      globalWindowMs: 60 * 60_000,
    },
    private readonly now: () => number = Date.now,
  ) {}

  isLocked(address: string): boolean {
    const time = this.now();
    this.global = this.global.filter((at) => time - at < this.options.globalWindowMs);
    const recent = (this.perAddress.get(address) ?? []).filter((at) => time - at < this.options.perAddressWindowMs);
    if (recent.length === 0) this.perAddress.delete(address);
    else this.perAddress.set(address, recent);
    return recent.length >= this.options.perAddressLimit || this.global.length >= this.options.globalLimit;
  }

  recordFailure(address: string): void {
    const time = this.now();
    this.global.push(time);
    const recent = this.perAddress.get(address) ?? [];
    recent.push(time);
    this.perAddress.set(address, recent);
    if (this.perAddress.size > 10_000) {
      const oldest = this.perAddress.keys().next().value;
      if (oldest !== undefined) this.perAddress.delete(oldest);
    }
  }

  recordSuccess(address: string): void {
    this.perAddress.delete(address);
  }
}
