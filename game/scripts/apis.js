function getWordsAPI() {
    if (isValidUrl(cloudWordsAPI)) {
        return cloudWordsAPI;
    }
    return localWordsAPI;
}

function getPlayerAPI() {
    if (isValidUrl(cloudPlayerAPI)) {
        return cloudPlayerAPI;
    }
    return localPlayerAPI;
}

function getGameAPI() {
    if (isValidUrl(cloudGameAPI)) {
        return cloudGameAPI;
    }
    return localGameAPI;
}

function getMetricsAPI() {
    if (isValidUrl(cloudMetricsAPI)) {
        return cloudMetricsAPI;
    }
    return localMetricsAPI;
}

function isValidUrl(string) {
  try {
    new URL(string);
    return true;
  } catch (err) {
    return false;
  }
}
