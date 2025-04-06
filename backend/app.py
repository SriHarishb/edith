from google import genai
from google.genai import types
from PIL import Image
from io import BytesIO
from flask import Flask, jsonify, request
import os
from pydub import AudioSegment
from google.cloud import texttospeech
from moviepy.editor import ImageSequenceClip, AudioFileClip
import numpy as np
from google.cloud import secretmanager
import firebase_admin
from firebase_admin import storage,credentials,firestore
from flask_cors import CORS
from dotenv import load_dotenv
load_dotenv()

# Initialize the credentials
cred = credentials.Certificate("service.json")
# Initialize the app with the credentials, and the storage bucket
firebase_admin.initialize_app(cred,{'storageBucket': os.getenv('BUCKET_ID')})
# Initialize Firestore DB
db = firestore.client()
# Initialize the path to the current directory
script_dir = os.path.dirname(__file__)

def get_secret(secret_name:str):
    '''Get the secret from the Secret Manager

    Args:
        secret_name (str): The name of the secret to retrieve
    
    Returns:
        str: The value of the secret
    '''

    client = secretmanager.SecretManagerServiceClient()
    project_id = "edith-454415"
    secret_path = f"projects/{project_id}/secrets/{secret_name}/versions/latest"
    response = client.access_secret_version(request={"name": secret_path})
    return response.payload.data.decode("UTF-8")

# Get the API key from the Secret Manager
api_key = get_secret("my-api-key")
n = len(api_key)
api_key = api_key[4:n-4]

# Initialize the client
client = genai.Client(api_key=api_key)


def generate_answer_para(text_data:str):
    '''Generate a detailed response to a question
    
    Args:
        text_data (str): The question to answer
    Returns:
        str: The generated answer
    '''


    contents = (f""" 
            You have been asked to write a detailed response in good English to the following question: {text_data}. 
            The answer should be less than 300 words.The response should not contain any punctuation marks except fullstop and commas.
            The response must contain full stops only at the end of each sentence.""")

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=contents,
        config=types.GenerateContentConfig(
            response_modalities=['Text']
        )
    )
    response_text = ''
    # Retrieving the text from the response
    for part in response.candidates[0].content.parts:
        if part.text is not None:
            response_text += part.text
    
    
    return response_text

def generate_title(text_data:str):
    '''Generate a title for the text data
    
    Args:
        text_data (str): The text data to generate a title for
    Returns:
        str: The generated title
    '''
    contents = (f""" 
            You have been asked to write a title in good English to the following para: {text_data}. 
            The title should be less than 10 words. Return only the title.
            The response should not contain any punctuation marks except fullstop and commas.
            """)

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=contents,
        config=types.GenerateContentConfig(
            response_modalities=['Text']
        )
    )
    response_text = ''
    # Retrieving the text from the response
    for part in response.candidates[0].content.parts:
        if part.text is not None:
            response_text += part.text
    # Format the text data to remove unwanted characters
    response_text = format_text(response_text)
    
    return response_text



def format_text(text_data:str):
    '''Format the text data to remove unwanted characters
    Args:
        text_data (str): The text data to format
    Returns:
        str: The formatted text data
    '''
    text_data = text_data.replace('\n', ' ').replace('\r', ' ').replace('\t', ' ')
    return text_data


def split_text(text_data:str):
    '''Split the text data into sentences
    Args:
        text_data (str): The text data to split
    Returns:
        list: The list of sentences
    '''
    text_data = [s.strip() for s in text_data.split('.') if s.strip()]
    return text_data

def generate_answer_image_prompts(text_data:list):
    '''Generate image prompts for each sentence in the text data
    Args:
        text_data (list): The list of sentences to generate image prompts for
    Returns:
        list: The list of image prompts'''
    

    contents = (f"""You are assigned with a job of converting each sentence in the list into
                good image prompts. The list is: {text_data}.
                Do not include any punctuation except for periods at the end of each sentence.
                The response should only contain the answer, no first person pronouns or any other unnecessary information.
                the sentence should be complete and make sense on its own. It should not include any pronouns, 
                only subject names should be provided.""")

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=contents,
        config=types.GenerateContentConfig(
            response_modalities=['Text']
        )
    )
    response_text = ''

    for part in response.candidates[0].content.parts:
        if part.text is not None:
            response_text += part.text
    prompt_list = split_text(text_data=response_text)
    return prompt_list

def generate_images(prompt_list:list):
    '''Generate images for each prompt in the prompt list
    Args:
        prompt_list (list): The list of prompts to generate images for each sentence
    Returns:
        list: The list of generated images
    '''
    images = []
    for prompt in prompt_list: 
            contents = f"""Generate an image of a creative scene of {prompt}.
            Use your own imagination to create the image.
            The image should be in good quality and should strictly not contain any text or watermarks.
            """

            response = client.models.generate_images(
            model='imagen-3.0-generate-002',
            prompt=contents,
            config=types.GenerateImagesConfig(
            number_of_images= 1,
            )
                )
            for generated_image in response.generated_images:
                    image = Image.open(BytesIO(generated_image.image.image_bytes))
                    images.append(image)
    return images


def generate_voice(text_data:str,user_name:str):
    '''Generate a voice for the text data
    Args:
        text_data (str): The text data to generate voice for
        user_name (str): The user name to save the voice file to
    Returns:
        bytes: The generated voice data
    '''
    # Instantiates a client
    ttsclient = texttospeech.TextToSpeechClient()

    # Set the text input to be synthesized
    synthesis_input = texttospeech.SynthesisInput(text=text_data)

    # Build the voice request, select the language code ("en-US") and the ssml
    voice = texttospeech.VoiceSelectionParams(
        language_code="en-US", ssml_gender=texttospeech.SsmlVoiceGender.NEUTRAL
    )

    # Select the type of audio file 
    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3
    )

    # Perform the text-to-speech request on the text input with the selected
    # voice parameters and audio file type
    response = ttsclient.synthesize_speech(
        input=synthesis_input, voice=voice, audio_config=audio_config
    )


    # The response's audio_content is binary.
    with open(f"{user_name}_output.mp3", "wb") as out:
        # Write the response to the output file.
        out.write(response.audio_content)
    return response.audio_content



def get_audio_duration(voice_bytes):
    '''Get the duration of the audio data
    Args:
        voice_bytes (bytes): The audio data in bytes
    Returns:
        float: The duration of the audio in seconds
    '''
    
    # Assuming 'audio_bytes' is the received audio data in bytes
    audio = AudioSegment.from_file(BytesIO(voice_bytes), format="mp3")  # Change format if needed

    # Get duration in seconds
    duration = len(audio) / 1000  # Convert milliseconds to seconds

    return duration

def estimate_tts_duration(text):
    '''Estimate the duration of a text-to-speech conversion
    Args:
        text (str): The text to convert to speech
    Returns:
        float: The estimated duration in seconds
    '''
    # Get the number of characters in the text
    char_count = len(text)

    # Approx Characters per second (cps) 
    cps = 16  # Default to WaveNet
    
    return round(char_count / cps, 2)  # Return duration in seconds

def adjust_frame_length(duration:float, text_data:str):
    '''Adjust the frame length to match the desired duration
    Args:
        duration (float): The desired duration in seconds
        text_data (str): The text data to convert to speech
    Returns:
        list: The list of frame durations
    '''

    # Initialize the empty list of estimated durations
    estimated_duration = []
    
    # Split the text data into sentences
    sentences = split_text(text_data)
    
    

    # Estimate the duration of each sentence
    for sentence in sentences:
        estimated_duration.append(estimate_tts_duration(sentence))
    
    # If the estimated duration is not equal to the desired duration
    if sum(estimated_duration) != duration:
        # Calculate the difference
        difference = duration - sum(estimated_duration)
        
        # Distribute the difference across all frames
        perframe = difference / len(estimated_duration)
        for i in range(len(estimated_duration)):
            estimated_duration[i] += perframe
        
        # Ensure the total duration matches the desired duration exactly
        # Adjust the last frame to account for any floating-point inaccuracies
        estimated_duration[-1] = duration - sum(estimated_duration[:-1])
    
    # Return the adjusted durations
    return estimated_duration


def merge_images(images:list,durations:list,user_id:str):
    '''Merge the images into a video clip and writes it to a file
    Args:
        images (list): The list of images to merge
        durations (list): The list of total durations
        user_id (str): The user ID to save the video to
    Returns:
        None    
    '''
    # Convert PIL images to NumPy arrays, resize them, and ensure they are RGB
    images = [np.array(img.convert("RGB").resize((1024, 500))) for img in images]

    # Create a video clip from images using fps instead of durations
    video_clip = ImageSequenceClip(images, durations=durations)

    # Load an audio file
    audio_clip = AudioFileClip(f"{user_id}_output.mp3")

    # Set audio to the video
    final_video = video_clip.set_audio(audio_clip)

    # Export the final video
    final_video.write_videofile(f"{user_id}_output_video.mp4", codec="libx264", fps=24)

    # Delete the audio file
    os.remove(f"{user_id}_output.mp3")

def count_videos_in_user_folder(user_id:str):
    '''Count the number of videos in the user's folder
    Args:
        user_id (str): The user ID to count videos for
    Returns:
        int: The number of videos in the user's folder
    '''

    # Get the storage bucket
    user = db.collection('users').document(user_id).get()
    # Get the user's video count
    user_dict = user.to_dict()
    # Fetch the user document to update the video count
    user_update  = db.collection('users').document(user_id)
    # Initialize the video count
    video_count = user_dict["video_count"]
    # Update the video count
    user_update.update({"video_count": video_count + 1})

    return video_count

def increment_views(user_id:str, video_url:str):
    '''Increment the views for a video in Firestore
    Args:
        user_id (str): The user ID to increment views for
        video_url (str): The video URL to increment views for
    Returns:
        None
    '''
    # Fetch the user document
    user = db.collection('users').document(user_id).get()
    # Get the user's video list
    user_dict = user.to_dict()
    # Get the user's video list
    video_list = user_dict["generated_videos"]
    # Find the video in the list and increment its views
    for video in video_list:
        if video["link"] == video_url:
            # Increment the views
            video["views"] += 1
            break
    # Update the user's video list in Firestore
    user_update = db.collection('users').document(user_id)
    # Update the user's video list
    user_update.update({"generated_videos": video_list})


def upload_to_firebase_storage(local_file_path:str, user_id:str,video_count:int):
    '''Upload a file to Firebase Storage
    Args:
        local_file_path (str): The local file path to upload
        user_id (str): The user ID to upload the file for
        video_count (int): The video count to upload the file for
    Returns:
        str: The public download URL of the uploaded file
    '''
    # Get the storage bucket
    bucket = storage.bucket()

    # Define the destination path in Firebase Storage
    destination_blob_name = f"users/{user_id}/videos/{video_count}"

    # Upload the file
    blob = bucket.blob(destination_blob_name)
    # Upload the file to Firebase Storage
    blob.upload_from_filename(local_file_path)
    # Delete the local file
    os.remove(local_file_path)
    # Make the file publicly accessible 
    blob.make_public()
    # Return the public download URL
    return blob.public_url

def write_to_firestore(user_id:str, video_url:str,video_title:str):
    '''Write the video URL to Firestore
    Args:
        user_id (str): The user ID to write the video URL for
        video_url (str): The video URL to write
        video_title (str): The title of the video
    Returns:
        list: The updated list of video URLs
    '''
    # Get the storage bucket
    user = db.collection('users').document(user_id).get()
    # Get the user's video list
    user_dict = user.to_dict()
    # Update the user's video list
    video_list = user_dict["generated_videos"]
    # Check if the video URL already exists in the list
    video_list.append({"views":0,"link":video_url,"title":video_title})
    # Update the user's video list in Firestore
    user_update = db.collection('users').document(user_id)
    # Update the user's video list
    user_update.update({"generated_videos": video_list})
    # Fetch the updated user document
    return video_list


def fetch_collection_recursively(collection_ref):
    """Recursively fetch all documents and subcollections in a Firestore collection.
    Args:
        collection_ref: A reference to the Firestore collection.
    Returns:
        A dictionary containing all documents and their subcollections.
    """
    # Initialize an empty dictionary to store the collection data
    collection_dict = {}

    # Stream all documents in the current collection
    for doc in collection_ref.stream():
        doc_data = doc.to_dict()  # Convert document to dictionary

        # Recursively fetch all subcollections of this document
        subcollections = doc.reference.collections()
        #  Iterate through each subcollection
        for subcollection in subcollections:
            subcollection_name = subcollection.id
            # Recursively fetch the subcollection data
            doc_data[subcollection_name] = fetch_collection_recursively(subcollection)

        # Add document data to the final collection dictionary
        collection_dict[doc.id] = doc_data

    return collection_dict

def search_all_videos(collection_ref,query:str):
    """Search all videos in a Firestore collection.
    Args:
        collection_ref: A reference to the Firestore collection.
        query (str): The search query to match against video titles.
    Returns:
        A list containing all videos.
    """
    # Initialize an empty list to store the video data
    video_list = []

    # Stream all documents in the current collection
    for doc in collection_ref.stream():
        doc_data = doc.to_dict()  # Convert document to dictionary
        doc_data = doc_data["generated_videos"]
        # Iterate through each document in the collection
        for video in doc_data:
            if "title" in video:
                title = video["title"]
                title = title.lower()
                if query.lower() in title:
                    # Check if the query is in the title
                    video_list.append(video)
    video_list.sort(key=lambda x: x['views'], reverse=True)
    return video_list

app = Flask(__name__)
CORS(app)

@app.route('/',methods=['POST'])
def generate_video():
   try:
        
        # Get the text data and user ID from the request
        text_data = request.json.get('text')
        user_id = request.json.get('user_id')
        # Validate the request
        if not text_data or user_id is None:
            return jsonify({'Error': 'Invalid request'}), 404
        # Format the text data
        response_text = generate_answer_para(text_data)
        # Generate a title for the text data
        title = generate_title(text_data)
        # Split the text data into sentences
        text_data = split_text(response_text)
        # Generate image prompts for each sentence
        prompt_list = generate_answer_image_prompts(text_data)
        # Generate images for each prompt
        images = generate_images(prompt_list)
        # Generate a voice for the text
        voice_bytes = generate_voice(response_text,user_name=user_id)
        # Get the duration of the audio
        duration = get_audio_duration(voice_bytes)
        # Adjust the frame length to match the desired duration
        total = adjust_frame_length(duration,response_text)
        # Merge the images into a video clip
        merge_images(images,total,user_id)
        # Count the number of videos in the user's folder
        video_count = count_videos_in_user_folder(user_id)
        # Upload the video to Firebase Storage
        video_url = upload_to_firebase_storage(f"{user_id}_output_video.mp4", user_id,video_count)
        # Write the video URL to Firestore
        video_list = write_to_firestore(user_id=user_id, video_url=video_url,video_title=title)
        # Return the video URL and success message
        return jsonify({'Success':'success','link':video_url}),200
   except Exception as e:
        # Check and delete files if they exist
        if os.path.exists(f"{user_id}_output.mp3"):
            os.remove(f"{user_id}_output.mp3")
        if os.path.exists(f"{user_id}_output_video.mp4"):
            os.remove(f"{user_id}_output_video.mp4")
        return jsonify({'error': str(e)}), 500



@app.route('/chat', methods=['POST'])
def chat():
    """
    Endpoint to handle multi-turn conversations with the Gemini API.
    Expects a JSON payload with 'user_id' and 'message'.
    Returns the AI's response in JSON format.
    """
    data = request.get_json()
    
    # Extract user_id and message from the request
    user_id = data.get('user_id')
    user_message = data.get('message')
    
    if not user_id or not user_message:
        return jsonify({"error": "Both 'user_id' and 'message' are required."}), 400

    # Generate the AI's response using the Gemini API
    try:
           
        # Start a chat session with the conversation history
        chat_session = client.chats.create(
            model="gemini-2.0-flash",
        )

        # Send the latest user message to the model
        response = chat_session.send_message(user_message)

        # Handle different response types
        if isinstance(response, str):
            response_text = response
        elif hasattr(response, 'text'):
            response_text = response.text
        elif isinstance(response, dict) and 'text' in response:
            response_text = response['text']
        else:
            raise ValueError(f"Unexpected response type: {type(response)}")
        # Return the AI's response
        return jsonify({"response": response_text})
    
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500    
    
@app.route('/create_user', methods = ['POST'])
def create_user():
    try:
        data = request.get_json()

        # Extract user_id and message from the request
        user_id = data.get('user_id')   
        data = {'generated_videos':[],'video_count':0}
        db.collection("users").document(user_id).set(data)
        return jsonify({'Success':'success'}),200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/get_user_videos', methods = ['POST'])
def get_user_videos():
    try:
        data = request.get_json()
        # Extract user_id and message from the request
        user_id = data.get('user_id')
        user = db.collection('users').document(user_id).get()
        user_dict = user.to_dict()
        video_list = user_dict["generated_videos"]
        return jsonify({'videos':video_list}),200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/get_all_videos', methods = ['GET'])
def get_all_videos():
    try:
        users = db.collection('users').stream()
        all_videos = []
        for user in users:
            user_dict = user.to_dict()
            video_list = user_dict["generated_videos"]
            if len(video_list) > 0:
                all_videos.extend(video_list)
        all_videos = sorted(all_videos, key=lambda x: x['views'], reverse=True)
        return jsonify({'videos':all_videos}),200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/get_path', methods = ['GET'])
def get_path():
    try:
        doc = db.collection('domains')
        # Fetch all documents in the collection
        documents = fetch_collection_recursively(doc)
        return jsonify(documents),200

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
@app.route('/increment_views', methods = ['POST'])
def increment_views_route():
    try:
        data = request.get_json()
        # Extract user_id and message from the request
        user_id = data.get('user_id')
        # Extract video_url from the request
        video_url = data.get('video_url')
        # Increment the views for the video in Firestore
        increment_views(user_id, video_url)
        return jsonify({'Success':'success'}),200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/search', methods = ['POST'])
def search():
    try:
        data = request.get_json()
        # Extract query from the request
        query = data.get('query')
        # Fetch all videos from Firestore
        doc = db.collection('users')
        video_list = search_all_videos(doc,query)
        return jsonify({'videos':video_list}),200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# Main entry point for running the Flask app 
if __name__ == '__main__':
    # Use the PORT environment variable 
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port,debug=True)