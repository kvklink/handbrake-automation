#!/usr/bin/env python3
import logging
import os
import subprocess
import time

from tendo import singleton

# Ensure only one instance is running at a time, to prevent duplicate conversion effort
me = singleton.SingleInstance()

logging.basicConfig(
    filename='/var/log/convert/debug.log', level=logging.DEBUG, format='%(asctime)s %(levelname)s: %(message)s'
)

movies_root_dir = os.environ.get('HANDBRAKE_MOVIES_SOURCE_DIR')
movies_target_dir = os.environ.get('HANDBRAKE_MOVIES_TARGET_DIR')
series_root_dir = os.environ.get('HANDBRAKE_SERIES_SOURCE_DIR')
series_target_dir = os.environ.get('HANDBRAKE_SERIES_TARGET_DIR')

custom_suffix = os.environ.get('HANDBRAKE_CUSTOM_SUFFIX')

if movies_root_dir is None or movies_target_dir is None or series_root_dir is None or series_target_dir is None:
    logging.error("Missing one or more of the required environment variables")
    exit("MISSING REQUIRED ENVIRONMENT VARIABLE. QUITTING.")

logging.info('\t--------------------------')
logging.info('\t-- Starting new session --')
logging.info('\t--------------------------\n')

handbrake_command = '/usr/bin/HandBrakeCLI -i "{0}" -o "{1}" --preset="High Profile" --x264-preset="veryfast" -E ca_aac'
file_list = []
logging.info(f'Looking for movies in {movies_root_dir}\n')

for root, sub_folders, files in os.walk(movies_root_dir):
    for file in files:
        the_file = os.path.join(root, file)
        file_name, file_extension = os.path.splitext(the_file)
        if file_extension.lower() in ('.mp4', '.avi', '.divx', '.flv', '.m4v', '.mkv', '.mov', '.mpg', '.mpeg', '.wmv'):
            logging.debug(f'Adding {the_file} to the conversion queue')
            file_list.append(the_file)


while file_list:
    in_file = file_list.pop()
    file_name, file_extension = os.path.splitext(in_file)
    out_file = f'{file_name}.{custom_suffix}.mp4' if custom_suffix else f'{file_name}.mp4'

    logging.info(f'Processing {in_file}')
    logging.debug(f'New file: {out_file}')

    if file_extension != '.mp4':
        return_code = subprocess.call(handbrake_command.format(in_file, file_name), shell=True)
        time.sleep(3)

        if return_code == 0:
            logging.debug(f'Deleting input file {in_file}')
            os.remove(in_file)

            logging.info(f'Moving new to {movies_target_dir}{os.path.basename(out_file)}')
            os.rename(file_name, f'{movies_target_dir}{os.path.basename(out_file)}')

        else:
            logging.error(f'Conversion failed with exit code {return_code}')
            logging.error(f"Didn't (re)move {in_file}")

    else:
        logging.debug(f'No conversion needed, moving file to {movies_target_dir}{os.path.basename(out_file)}')
        os.rename(in_file, f'{movies_target_dir}{os.path.basename(out_file)}')

    pass

file_list = []
logging.info(f'Looking for series in {series_root_dir}\n')

for root, sub_folders, files in os.walk(series_root_dir):
    for file in files:
        the_file = os.path.join(root, file)
        file_name, file_extension = os.path.splitext(the_file)
        if file_extension.lower() in ('.mp4', '.avi', '.divx', '.flv', '.m4v', '.mkv', '.mov', '.mpg', '.mpeg', '.wmv'):
            logging.debug(f'Adding {the_file} to the conversion queue')
            file_list.append(the_file)


while file_list:
    in_file = file_list.pop()
    file_name, file_extension = os.path.splitext(in_file)
    out_file = f'{file_name}.{custom_suffix}.mp4' if custom_suffix else f'{file_name}.mp4'

    logging.info(f'Processing {in_file}')
    logging.debug(f'New file: {out_file}')

    if file_extension != '.mp4':

        return_code = subprocess.call(handbrake_command.format(in_file, file_name), shell=True)
        time.sleep(3)

        if return_code == 0:
            logging.debug(f'Deleting input file {in_file}')
            os.remove(in_file)

            logging.debug(f'Moving new to {series_target_dir}{os.path.basename(out_file)}')
            os.rename(file_name, f'{series_target_dir}{os.path.basename(out_file)}')

        else:
            logging.error(f'Conversion failed with exit code {return_code}')
            logging.error(f"Didn't (re)move {in_file}")

    else:
        logging.debug(f'No conversion needed, moving file to {series_target_dir}{os.path.basename(out_file)}')
        os.rename(in_file, f'{series_target_dir}{os.path.basename(out_file)}')

    pass

logging.info('Finished conversion jobs, will schedule shutdown in 2 minutes')
# We wait for two minutes before issuing the shutdown command. This way, someone would still be able to quickly log in
# The shutdown is then scheduled one minute ahead, which makes it possible to cancel it altogether when logged in
time.sleep(120)
subprocess.call('sudo shutdown -h +1', shell=True)
