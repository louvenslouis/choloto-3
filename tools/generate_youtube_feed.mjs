import {readFile, writeFile} from "node:fs/promises";

const channelId = "UC6N0qcctRmlaUEYdzhR0-Hw";
const channelUrl = `https://www.youtube.com/channel/${channelId}/videos`;
const outputPath = process.argv[2] || "web/youtube-feed.json";
const maxVideos = 24;

function extractJsonObject(source, marker) {
  const markerIndex = source.indexOf(marker);
  if (markerIndex === -1) return null;

  const start = source.indexOf("{", markerIndex + marker.length);
  if (start === -1) return null;

  let depth = 0;
  let inString = false;
  let escaped = false;

  for (let index = start; index < source.length; index += 1) {
    const character = source[index];

    if (inString) {
      if (escaped) escaped = false;
      else if (character === "\\") escaped = true;
      else if (character === '"') inString = false;
      continue;
    }

    if (character === '"') inString = true;
    else if (character === "{") depth += 1;
    else if (character === "}") {
      depth -= 1;
      if (depth === 0) return source.slice(start, index + 1);
    }
  }

  return null;
}

function textFromRuns(value) {
  if (typeof value?.simpleText === "string") return value.simpleText;
  return Array.isArray(value?.runs)
    ? value.runs.map((run) => run.text || "").join("")
    : "";
}

function approximatePublishedDate(relativeText, now = new Date()) {
  const normalized = relativeText?.toLowerCase().trim() || "";
  const match = normalized.match(
    /(\d+)\s+(second|minute|hour|day|week|month|year)s?\s+ago/,
  );

  if (normalized === "today") return now.toISOString();
  if (normalized === "yesterday") {
    return new Date(now.getTime() - 86400000).toISOString();
  }
  if (!match) return "";

  const milliseconds = {
    second: 1000,
    minute: 60000,
    hour: 3600000,
    day: 86400000,
    week: 604800000,
    month: 2629800000,
    year: 31557600000,
  }[match[2]];

  return new Date(now.getTime() - Number(match[1]) * milliseconds).toISOString();
}

function videoItem(videoId, title, pubDate) {
  if (!videoId || !title?.trim()) return null;
  return {
    title: title.trim(),
    link: `https://www.youtube.com/watch?v=${videoId}`,
    thumbnail: `https://i.ytimg.com/vi/${videoId}/hqdefault.jpg`,
    pubDate: pubDate || "",
  };
}

function fromLockup(model, now) {
  const metadata = model.metadata?.lockupMetadataViewModel;
  const videoId = model.rendererContext?.commandContext?.onTap
    ?.innertubeCommand?.watchEndpoint?.videoId;
  const metadataParts =
    metadata?.metadata?.contentMetadataViewModel?.metadataRows
      ?.flatMap((row) => row.metadataParts || []) || [];
  const publishedText = metadataParts
    .map((part) => part.text?.content || part.accessibilityLabel || "")
    .find((text) => /ago$|today$|yesterday$/i.test(text.trim()));

  return videoItem(
    videoId,
    metadata?.title?.content,
    approximatePublishedDate(publishedText, now),
  );
}

function fromVideoRenderer(renderer, now) {
  return videoItem(
    renderer.videoId,
    textFromRuns(renderer.title),
    approximatePublishedDate(textFromRuns(renderer.publishedTimeText), now),
  );
}

export function parseYoutubeVideos(html, now = new Date()) {
  const jsonSource =
    extractJsonObject(html, "var ytInitialData =") ||
    extractJsonObject(html, 'window["ytInitialData"] =');
  if (!jsonSource) throw new Error("YouTube initial data was not found.");

  const initialData = JSON.parse(jsonSource);
  const items = [];
  const seen = new Map();

  function add(item) {
    if (!item) return;
    const videoId = new URL(item.link).searchParams.get("v");
    if (!videoId) return;
    if (seen.has(videoId)) {
      const existingIndex = seen.get(videoId);
      if (!items[existingIndex].pubDate && item.pubDate) {
        items[existingIndex] = item;
      }
      return;
    }
    if (items.length >= maxVideos) return;
    seen.set(videoId, items.length);
    items.push(item);
  }

  function visit(value) {
    if (!value || typeof value !== "object") {
      return;
    }
    if (value.lockupViewModel) add(fromLockup(value.lockupViewModel, now));
    if (value.videoRenderer) add(fromVideoRenderer(value.videoRenderer, now));
    Object.values(value).forEach(visit);
  }

  visit(initialData);
  if (items.length === 0) throw new Error("No public videos were found.");
  return items;
}

async function generateFeed() {
  const response = await fetch(channelUrl, {
    headers: {
      Accept: "text/html,application/xhtml+xml",
      "Accept-Language": "en-US,en;q=0.9",
      "User-Agent":
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 " +
        "(KHTML, like Gecko) Chrome/124.0 Safari/537.36",
    },
  });
  if (!response.ok) throw new Error(`YouTube returned HTTP ${response.status}.`);

  const items = parseYoutubeVideos(await response.text());
  await writeFile(
    outputPath,
    `${JSON.stringify({items, updatedAt: new Date().toISOString()}, null, 2)}\n`,
  );
  console.log(`Wrote ${items.length} videos to ${outputPath}.`);
}

try {
  await generateFeed();
} catch (error) {
  try {
    JSON.parse(await readFile(outputPath, "utf8"));
    console.warn(`Feed refresh failed; keeping ${outputPath}: ${error.message}`);
  } catch (_) {
    throw error;
  }
}
