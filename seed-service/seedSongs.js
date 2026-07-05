// seedSongs.js
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import mongoose from "mongoose";
import Song from "./models/Song.js"; // your mongoose model

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const SONGS_DIR = path.join(__dirname, "songs");
const COVER_DIR = path.join(__dirname, "cover-images");
const METADATA_PATH = path.join(__dirname, "songs-metadata.json");

const createSong = async (req, res, next) => {
  try {
    if (!req.files || !req.files.audioFile || !req.files.imageFile) {
      return res.status(400).json({ message: "Please upload all files" });
    }

    const { title, artist, albumId, duration } = req.body;
    const audioFile = req.files.audioFile;
    const imageFile = req.files.imageFile;

    const audioUrl = await uploadToS3(audioFile, "audio");
    const imageUrl = await uploadToS3(imageFile, "image");

    const song = await Song.create({ title, artist, albumId, duration, audioUrl, imageUrl });

    res.status(201).json(song);
  } catch (error) {
    next(error);
  }
};

const saveSong = async ({ title, artist, albumId, duration, audioFilePath, imageFilePath }) => {
    
  const audioFile = {
    name: path.basename(audioFilePath),
    tempFilePath: audioFilePath,
    mimetype: "audio/mpeg", // adjust based on ext if needed
  };

  const imageFile = {
    name: path.basename(imageFilePath),
    tempFilePath: imageFilePath,
    mimetype: "image/jpeg", // adjust based on ext if needed
  };

  const audioUrl = await uploadToS3(audioFile, "audio");
  const imageUrl = await uploadToS3(imageFile, "image");

  const song = await Song.create({
    title,
    artist,
    albumId,
    duration,
    audioUrl,
    imageUrl,
  });

  return song;
};


const seedSongs = async () => {

  try {
    await mongoose.connect(process.env.MONGODB_URI);

    const metadata = JSON.parse(fs.readFileSync(METADATA_PATH, "utf-8"));

    // loop through each object in songs-metadata.json
    for (const entry of metadata) {

      const { title, artist, duration, audioFileName, imageFileName } = entry;

      const audioFilePath = path.join(SONGS_DIR, audioFileName);
      const imageFilePath = path.join(COVER_DIR, imageFileName);

      if (!fs.existsSync(audioFilePath) || !fs.existsSync(imageFilePath)) {
        console.warn(`Skipping "${title}" — missing file(s)`);
        continue;
      }

      console.log(`Uploading: ${title}`);

      // upload to s3 and save to db
      const song = await saveSong({
        title,
        artist,
        albumId,
        duration,
        audioFilePath,
        imageFilePath,
      });

      console.log(`✅ Saved: ${song.title} (${song._id})`);
    }

    console.log("Seeding complete.");
    process.exit(0);
  } catch (error) {
    console.error("Error seeding songs:", error);
    process.exit(1);
  }
};

seedSongs();