export function formatCurrency(amountInCents: number, currency: string) {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency,
    maximumFractionDigits: 0
  }).format(amountInCents / 100);
}

export function titleize(value: string | undefined | null) {
  if (!value) return "";
  return value.replaceAll("_", " ").replace(/\b\w/g, (letter) => letter.toUpperCase());
}
