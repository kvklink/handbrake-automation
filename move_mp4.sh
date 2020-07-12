#!/usr/bin/env python3
import logging
import os
import subprocess

from tendo import singleton

me = singleton.SingleInstance()

logging.basicConfig(
    filename='/var/log/movemp4.log', level=logging.DEBUG, format='%(asctime)s %(levelname)s: %(message)s'
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

logging.debug(f'Looking for movies in {movies_root_dir}')

conversion = False

for root, sub_folders, files in os.walk(movies_root_dir):
    for file in files:
        the_file = os.path.join(root, file)
        file_name, file_extension = os.path.splitext(the_file)
        if file_extension.lower() == '.mp4':
            newFile = f'{os.path.basename(file_name)}.{custom_suffix}.mp4' if custom_suffix \
                else f'{os.path.basename(file_name)}.mp4'
            logging.debug('Found ' + the_file)

            logging.debug(f'Moving to {movies_target_dir}{newFile}')
            os.rename(the_file, f'{movies_target_dir}{newFile}')

        if file_extension.lower() in ('.avi', '.divx', '.flv', '.m4v', '.mkv', '.mov', '.mpg', '.mpeg', '.wmv') \
                and not conversion:
            logging.debug('Found at least one file that needs to be converted, sending magic packet')
            conversion = True

logging.debug(f'Looking for series in {series_root_dir}')

for root, sub_folders, files in os.walk(series_root_dir):
    for file in files:
        the_file = os.path.join(root, file)
        file_name, file_extension = os.path.splitext(the_file)
        if file_extension.lower() == '.mp4':
            newFile = f'{os.path.basename(file_name)}.{custom_suffix}.mp4' if custom_suffix \
                else f'{os.path.basename(file_name)}.mp4'
            logging.debug(f'Found {the_file}')

            logging.debug(f'Moving to {series_target_dir}{newFile}')
            os.rename(the_file, f'{series_target_dir}{newFile}')

        if file_extension.lower() in ('.avi', '.divx', '.flv', '.m4v', '.mkv', '.mov', '.mpg', '.mpeg', '.wmv') \
                and not conversion:
            logging.debug('Found at least one file that needs to be converted, sending magic packet')
            conversion = True

if conversion:
    remote_mac = os.environ.get('HANDBRAKE_WAKEUP_MAC')
    return_code = subprocess.call(f'wakeonlan {remote_mac}', shell=True)

    logging.debug('Done on this end, waiting for files to get converted')
else:
    logging.debug("All files have been moved. We're done here")
