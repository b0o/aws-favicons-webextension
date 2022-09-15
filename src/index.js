import {
  getAwsServiceForURL,
  getLocalFaviconURL,
  setFavicon,
} from "./aws-favicons"

import services from "../services.json"

const main = async () => {
  const service = getAwsServiceForURL(services, window.location)
  if (service) {
    await setFavicon(getLocalFaviconURL(service))
  }
}

if (typeof window !== "undefined") {
  if (document.head) {
    main()
  } else {
    window.addEventListener("load", main)
  }
}
