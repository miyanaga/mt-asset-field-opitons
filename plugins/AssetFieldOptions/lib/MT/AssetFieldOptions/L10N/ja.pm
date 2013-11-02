package MT::AssetFieldOptions::L10N::ja;

use strict;
use utf8;
use base 'MT::AssetFieldOptions::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
	'AssetFieldOptions' => 'アイテムカスタムフィールド追加オプション',
	'Adds options to Asset typed field such as resolution of image.'
		=> 'アイテムを選択するカスタムフィールドに、画像の解像度といったオプションを追加します。',
	'Please enter size: WxH; (ex: size: 320x240;) if you want to fix size for an image.'
		=> '選択できる画像の解像度を指定するには、size: WxH; (例: size: 320x120; )を入力してください',
	'Size must be [_1]x[_2] pixels.' => '解像度が[_1]×[_2]の画像を選択してください',
	'Image is not match [_1]x[_2] pixels.' => '画像が[_1]×[_2]ピクセルの解像度に一致しません',
);

1;

