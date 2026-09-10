import assert from "node:assert/strict";
import test from "node:test";

import {parseYoutubeAtomFeed} from "./generate_youtube_feed.mjs";

test("parses stable Atom publication dates and decoded titles", () => {
  const xml = `
    <feed xmlns:yt="http://www.youtube.com/xml/schemas/2015">
      <entry>
        <yt:videoId>fresh123</yt:videoId>
        <title>CHOLOTO &amp; zanmi</title>
        <published>2026-09-10T14:05:00+00:00</published>
      </entry>
    </feed>`;

  assert.deepEqual(parseYoutubeAtomFeed(xml), [
    {
      title: "CHOLOTO & zanmi",
      link: "https://www.youtube.com/watch?v=fresh123",
      thumbnail: "https://i.ytimg.com/vi/fresh123/hqdefault.jpg",
      pubDate: "2026-09-10T14:05:00+00:00",
    },
  ]);
});

test("rejects an Atom response without usable entries", () => {
  assert.throws(() => parseYoutubeAtomFeed("<feed></feed>"));
});
