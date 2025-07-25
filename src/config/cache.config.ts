import { registerAs } from "@nestjs/config";

export default registerAs("cache", () => ({
  host: process.env.REDIS_HOST || "localhost",
  port: Number.parseInt(process.env.REDIS_PORT || "6379", 10),
  password: process.env.REDIS_PASSWORD,
  ttl: Number.parseInt(process.env.REDIS_TTL || "3600", 10), // Time to live in seconds
}));
