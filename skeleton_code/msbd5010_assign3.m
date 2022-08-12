% MSBD5010_ASSIGN3 MSBD5010 assignment 3 main routine.
%
function msbd5010_assign3()
clc;
clear;
close all;

%warp_ImFilePath = 'warp_imgs/';
%seg_ImFilePath = 'seg_imgs/';
% FOR WINDOWS USERS
warp_ImFilePath = 'warp_imgs\';
seg_ImFilePath = 'seg_imgs\';

warp_routine(warp_ImFilePath);
seg_routine(seg_ImFilePath);


jpeg_ImFileName = 'lenaTest1.jpg';
jpeg_Im = imread(jpeg_ImFileName);

compression_jpeg(jpeg_Im);

disp('Done.');
