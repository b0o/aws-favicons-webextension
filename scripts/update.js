import { awsBaseURL } from "../src/aws-favicons"
import { readFileSync } from "fs"

const input = readFileSync(0, "utf-8")
const res = JSON.parse(input).services.reduce(
  (acc, s) =>
    s.icon
      ? {
          ...acc,
          [awsBaseURL(s.url)]: { icon: s.icon, id: s.id },
        }
      : acc,
  {}
)

// eslint-disable-next-line no-undef
process.stdout.write(JSON.stringify(res))
