const awsBaseURL = (u) => {
  if (typeof u === "string" && !u.match(/^http(s)?:\/\//)) {
    const _u = new URL("https://console.aws.amazon.com");
    _u.pathname = u;
    u = _u;
  }
  const url = u instanceof URL ? u : new URL(u);
  url.search = "";
  url.hash = "";
  url.pathname = url.pathname.split("/").at(1) ?? "";
  url.hostname = url.hostname.replace(
    /[^.]+\.(console\.aws\.amazon\.com)$/,
    "$1"
  );
  return `${url.hostname}${url.pathname
    .replace(/\/+/, "/")
    .replace(/\/$/, "")}`;
};

const getAwsServices = async () => {
  const url = chrome.extension.getURL("/services.json");
  return (await fetch(url)).json();
};

const getAwsServiceForURL = (services, url) => {
  const bu = awsBaseURL(url);
  return services[bu];
};

const getLocalFaviconURL = (service) =>
  chrome.extension.getURL(`/icons/${service.id}.svg`);

const setFavicon = async (href) => {
  let link = document.querySelector("link[rel=icon]");
  if (link) {
    if (link.href === href) {
      return;
    }
  } else {
    link = document.createElement("link");
    document.head.appendChild(link);
  }
  link.type = "image/svg+xml";
  link.rel = "icon";
  link.href = href;
};

const main = async () => {
  const services = await getAwsServices();
  const service = getAwsServiceForURL(services, window.location);
  if (service) {
    await setFavicon(getLocalFaviconURL(service));
  }
};

if (typeof module === "object" && module.exports) {
  module.exports.awsBaseURL = awsBaseURL;
} else {
  main();
}
