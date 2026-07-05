// seedSongs.js
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import mongoose from "mongoose";
// import { Song } from "../models/song.model.js";
import { GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import s3Client from "../lib/s3.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const SONGS_DIR = path.join(__dirname, "songs");
const COVER_DIR = path.join(__dirname, "cover-images");
const METADATA_PATH = path.join(__dirname, "songs-metadata.json");

import mongoose from "mongoose";

const songSchema = new mongoose.Schema(
	{
		title: {
			type: String,
			required: true,
		},
		artist: {
			type: String,
			required: true,
		},
		imageUrl: {
			type: String,
			required: true,
		},
		audioUrl: {
			type: String,
			required: true,
		},
		duration: {
			type: Number,
			required: true,
		},
		albumId: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "Album",
			required: false,
		},
	},
	{ timestamps: true }
);

const Song = mongoose.model("Song", songSchema);

const uploadToS3 = async (file, uploadKey) => {
  try {

    let key = ""
    const ext = path.extname(file.name);
    if (uploadKey === "audio"){
      key = `songs/${crypto.randomUUID()}${ext}`;
    }else if (uploadKey === "image") {
      key = `thumbnail/${crypto.randomUUID()}${ext}`;
    }

    const result = await s3Client.send(
      new PutObjectCommand({
        Bucket: process.env.S3_BUCKET_NAME,
        Key: key,
        Body: fs.createReadStream(file.tempFilePath),
        ContentType: file.mimetype
      })
    );

    return key;

  } catch (error) {
    console.log("Error while uploading to S3", error);
    throw new Error("Error uploading to S3");
  }
};

const saveSong = async ({ title, artist, albumId, duration, audioFilePath, imageFilePath }) => {
  try{ 
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

    const song = new Song({
      title,
      artist,
      audioUrl,
      imageUrl,
      duration,
      albumId: albumId || null,
    });
    
    await song.save();

    // if song belongs to an album, update the album's songs array
    if (albumId) {
      await Album.findByIdAndUpdate(albumId, {
        $push: { songs: song._id },
      });
    }
    return song;
  } catch (error) {
		console.log("Error in saving song", error);
    throw new Error("Error saving songs");
	}
};


const seedSongs = async () => {

  try {

    // create database connection
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

      console.log(`✅ Saved: ${song.title}`);
    }

    console.log("Seeding complete.");
    process.exit(0);
  } catch (error) {
    console.error("Error seeding songs:", error);
    process.exit(1);
  }
};

seedSongs();