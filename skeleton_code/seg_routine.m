function seg_routine(PATH)

inputs = [1 2];
img_name = [PATH, num2str(inputs(1)), '.jpg'];
img = imread(img_name);
Im = rgb2gray(img);
[digits_set] = digit_segment(Im, 15, 15);

[M, sze] = size(digits_set);
figure,
first = round(M / 2);
for i = 1: first
	digit = digits_set(i, :);
    digit = reshape(digit, sqrt(length(digit)), sqrt(length(digit)));
    subplot(2,first,i)
    imshow(digit);
    %imshow(digit, []);
end
for i = first + 1: M
	digit = digits_set(i, :);
    digit = reshape(digit, sqrt(length(digit)), sqrt(length(digit)));
    subplot(2,first,i)
    imshow(digit);
    %imshow(digit, []);
end


img_name = [PATH, num2str(inputs(2)), '.jpg'];
img = imread(img_name);
Im = rgb2gray(img);
[digits_set] = digit_segment(Im, 25, 10);

[M, sze] = size(digits_set);

figure,
first = round(M / 2);
for i = 1: first
	digit = digits_set(i, :);
    digit = reshape(digit, sqrt(length(digit)), sqrt(length(digit)));
    subplot(2,first,i)
    imshow(digit);
    %imshow(digit, []);
end
for i = first + 1: M
	digit = digits_set(i, :);
    digit = reshape(digit, sqrt(length(digit)), sqrt(length(digit)));
    subplot(2,first,i)
    imshow(digit);
    %imshow(digit, []);
end
