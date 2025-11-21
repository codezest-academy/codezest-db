import { describe, it, expect } from "vitest";
import { prisma } from "../src/index";

describe("Database Package", () => {
  it("should export prisma client", () => {
    expect(prisma).toBeDefined();
  });

  it("should have valid configuration", () => {
    expect(process.env.DATABASE_URL).toBeDefined();
  });
});
