import os
import discord
from discord.ext import commands, tasks
import asyncio
import requests
from google import genai
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Load secrets from environment
DISCORD_TOKEN = os.getenv('DISCORD_TOKEN')
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
CHANNEL_ID = 1329517972456210483  # replace with your channel ID

# Check if environment variables are set
if not DISCORD_TOKEN or not GEMINI_API_KEY:
    raise ValueError("Missing required environment variables. Please set DISCORD_TOKEN and GEMINI_API_KEY in .env file.")

bot = commands.Bot(command_prefix="!", self_bot=False)

# Initialize the Gemini client
client = genai.Client(api_key=GEMINI_API_KEY)

@bot.event
async def on_ready():
    print(f"Logged in as {bot.user}")
    message_loop.start()

@tasks.loop(minutes=1.1)
async def message_loop():
    channel = bot.get_channel(CHANNEL_ID)
    if not channel:
        print("Channel not found; check CHANNEL_ID")
        return

    # Call Gemini API
    try:
        # Using the current client approach
        response = client.models.generate_content(
            model="gemini-2.0-flash",
            contents="Ask a random short question about Solo Leveling. Ask is if you're talking to a friend. Or you can also say you're favorite character in Solo Leveling. Don't use emojis."
        )
        random_message = response.text
    except Exception as e:
        random_message = f"⚠️ Error fetching from Gemini: {e}"
        print(e)

    # Send & delete
    msg = await channel.send(random_message)
    print(f"Sent: {random_message!r}")

bot.run(DISCORD_TOKEN, bot=False)