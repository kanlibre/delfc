#============================================================================================================
#	拡張機能 - 無効バイトシーケンス除去
#	0ch_delfc.pl
#	--------------------------------------------------------------------------------------------
#	かんりぶれ★ with ﾘ*"ﾌ")ﾚ の みんな ( https://boumou.li/ )
#
#	Last up date 2024.08.09
#============================================================================================================
package ZPL_delfc;

use Encode;
#------------------------------------------------------------------------------------------------------------
#	拡張機能名称取得
#------------------------------------------------------------------------------------------------------------
sub getName
{
	return '無効バイトシーケンス除去';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能説明取得
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	return '無効なバイトシーケンスを除去';
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能タイプ取得
#------------------------------------------------------------------------------------------------------------
sub getType
{
	return 16;
}

#------------------------------------------------------------------------------------------------------------
#	設定リスト取得 (0ch+ Only)
#------------------------------------------------------------------------------------------------------------
sub getConfig
{
	return {};
}

#------------------------------------------------------------------------------------------------------------
#	拡張機能実行インタフェイス
#------------------------------------------------------------------------------------------------------------
sub execute
{
	my $this = shift;
	my ($Sys, $Form, $type) = @_;
	
	# 0ch本家では実行しない
	return 0 if (!$this->{'is0ch+'});
	
	# フォームを取得
	my $msg = $Form->Get('MESSAGE');
	my $name = $Form->Get('FROM');
	my $mail = $Form->Get('MAIL');
	my $tt = $Form->Get('subject');

	# 本文
	$msg = replace_cmd($msg);
	$Form->Set('MESSAGE', $msg);

	# 名前欄
	if ($name ne '') {
		$name = replace_cmd($name);
		$Form->Set('FROM', $name);
	}

	# メール欄
	if ($mail ne '') {
		$name = replace_cmd($mail);
		$Form->Set('MAIL', $mail);
	}
	
	# スレタイ
	if ($tt ne '') {
		$tt = replace_cmd($tt);
		$Form->Set('subject', $tt);
	}
	
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#	無効なバイトシーケンス除去処理
#------------------------------------------------------------------------------------------------------------
sub replace_cmd
{
	my $text = shift;

    # 無効なバイトシーケンスが含まれているかチェック
    my $decoded_text;
    eval {
		$decoded_text = $text;
        $decoded_text = Encode::decode('shiftjis', $decoded_text, Encode::FB_CROAK);
    };

    if ($@) {
        # エラーの場合、U+FFFD を挿入してデコード
        $decoded_text = Encode::decode('shiftjis', $text, Encode::FB_DEFAULT);
        
        # U+FFFD (不正な文字を表す置換文字) を除去
        $decoded_text =~ s/\x{FFFD}//g;
        
        return Encode::encode('shiftjis', $decoded_text);
    }

    # 無効なバイトシーケンスがなければそのまま返す
    return $text;
}

#------------------------------------------------------------------------------------------------------------
#	コンストラクタ
#------------------------------------------------------------------------------------------------------------
sub new
{
	my $class = shift;
	my ($Config) = @_;
	
	my $this = {};
	bless $this, $class;
	
	if (defined $Config) {
		$this->{'PLUGINCONF'} = $Config;
		$this->{'is0ch+'} = 1;
	}
	else {
		$this->{'CONFIG'} = $class->getConfig();
		$this->{'is0ch+'} = 0;
	}
	
	return $this;
}

#------------------------------------------------------------------------------------------------------------
#	設定値取得 (0ch+ Only)
#------------------------------------------------------------------------------------------------------------
sub GetConf
{
	my $this = shift;
	my ($key) = @_;
	if ($this->{'is0ch+'}) {
		return $this->{'PLUGINCONF'}->GetConfig($key);
	}
	elsif (defined $this->{'CONFIG'}->{$key}) {
		return $this->{'CONFIG'}->{$key}->{'default'};
	}
}

#------------------------------------------------------------------------------------------------------------
#	設定値設定 (0ch+ Only)
#------------------------------------------------------------------------------------------------------------
sub SetConf
{
	my $this = shift;
	my ($key, $val) = @_;
	if ($this->{'is0ch+'}) {
		$this->{'PLUGINCONF'}->SetConfig($key, $val);
	}
	elsif (defined $this->{'CONFIG'}->{$key}) {
		$this->{'CONFIG'}->{$key}->{'default'} = $val;
	}
	else {
		$this->{'CONFIG'}->{$key} = { 'default' => $val };
	}
}

#============================================================================================================
#	Module END
#============================================================================================================
1;