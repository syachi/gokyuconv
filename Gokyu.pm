use strict;
use warnings;
use utf8;
use Text::MeCab;
use Encode qw(decode_utf8);

# See http://perl-users.jp/articles/advent-calendar/2010/acme/21

sub conv
{
    my $input = shift;
    my $verbose = 0;
    my $parser = Text::MeCab->new();
    my @r; # result
    my @nodes;
    for my $text (split /(\s+)/, $input) {
        if ($text =~ /\s/) {
            push @r, $text;
            next;
        }
        # 前後の関係を把握するため一旦配列にまとめる
        my @nodes;
        foreach (my $node = $parser->parse($text); $node; $node = $node->next) {
            next if $node->stat =~ /[23]/; # skip MECAB_(BOS|EOS)_NODE
            my $surface = decode_utf8($node->surface);
            my $feature = decode_utf8($node->feature);
            my @feature = split ',', $feature;
            push @nodes, {surface => $surface, feature => \@feature};
        }

        my $count = 0;
        my $nodes_count = $#nodes + 1;
        for(my $i = 0; $i < @nodes; $i++) {

            $count++;

            # 一つ前
            my ($_s, @_f) = $count == 1 ? ('', ('','','','','','','','')) : ($nodes[$i - 1]->{surface}, @{$nodes[$i - 1]->{feature}});
            # 今
            my ($s, @f) = ($nodes[$i]->{surface}, @{$nodes[$i]->{feature}});
            # ひとつ後
            my ($s_, @f_) = $count == $nodes_count ? ('', ('','','','','','','','','')) : ($nodes[$i + 1]->{surface}, @{$nodes[$i + 1]->{feature}});

            if (($s eq 'わたし' || $s eq '私') and $f[0] eq '名詞' and $f[1] eq '代名詞') {
                push @r, 'ワダヂ';
            } elsif ($s eq 'たら' and $f[0] eq '助動詞') {
                push @r, 'たらア';
            } elsif ($s eq 'この' and $f[0] eq '連体詞') {
                my $mod = $count % 4;
                push @r, $mod == 0 ? 'ゴノ、ゴノ'
                       : $mod == 1 ? 'ゴノ！'
                       : 'この';
            } elsif (($s eq 'だけど' || $s eq 'けれども' || $s eq 'しかし' || $s eq 'でも') and $f[0] eq '接続詞') {
                push @r, 'せやけど' . (($count % 2) ? '' : '！');
            } elsif ($s eq 'という' and $f[0] eq '助詞' and $f[1] eq '格助詞' and $f[2] eq '連語') {
                push @r, 'っていう';
            } elsif ($s eq 'を' and $f[0] eq '助詞' and $f[1] eq '格助詞') {
                my $mod = $count % 4;
                push @r, $mod == 0 ? 'を！ウグッブーン！！'
                       : $mod == 1 ? 'を！　ゥ'
                       : $mod == 2 ? 'を！！'
                       : $mod == 3 ? 'を、'
                       : 'を';
            } elsif ($s eq 'の' and $f[0] eq '助詞' and $f[1] eq '連体化')  {
                my $mod = $count % 10;
                push @r, $mod < 0 ? 'のッハアーーーー！'
                       : $mod < 3 ? 'ノォォー、ウェエ、'
                       : $mod < 4 ? 'のブッヒィフエエエーーーーンン！！　ヒィェーーッフウンン！！　ウゥ……ウゥ……。ア゛ーーーーーア゛ッア゛ーー！！！！'
                       : $mod < 8 ? 'の！'
                       : 'の、';
            } elsif ($s eq 'たら' and $f[0] eq '助動詞') {
                push @r, 'たらア';
            } elsif ($s eq 'ください' and $f[0] eq '動詞' and $f[1] eq '非自立') {
                push @r, 'ぐだざい！！';
            } elsif ($s eq 'が' and $f[0] eq '助詞' and $f[1] eq '格助詞' and $f[2] eq '一般') {
                my $mod = $count % 4;
                push @r, $mod == 0 ? 'がね゛ぇ！'
                       : $mod == 1 ? 'ガッハッハアン！！ア゛ーー'
                       : $mod == 2 ? 'がああ！'
                       : 'が！';
            } elsif ($s eq 'で' and $f[0] eq '助詞' and $f[1] eq '格助詞' and $f[2] eq '一般' and $f_[0] ne '助詞') {
                my $mod = $count % 2;
                push @r, $mod == 0 ? 'でェえ！'
                       : 'でイェーヒッフア゛ーー！！！　……ッウ、ック。';
            } elsif ($s eq 'に' and $f[0] eq '助詞' and $f[1] eq '格助詞' and $f[2] eq '一般') {
                my $mod = $count % 2;
                push @r, $mod == 0 ? 'に！！'
                       : 'に';
            } elsif ($s eq 'は' and $f[0] eq '助詞' and $f[1] eq '係助詞') {
                my $mod = $count % 4;
                push @r, $mod == 0 ? 'ハネェ！'
                       : $mod == 1 ? 'ッハアアアァアーー！！'
                       : $mod == 2 ? 'ッハアアアァアーー！！'
                       : $mod == 3 ? 'はー！'
                       : 'は';
            } elsif ($s eq 'ので' and $f[0] eq '助詞' and $f[1] eq '接続助詞') {
                push @r, 'から！';
            } elsif ($s eq 'しっかり' and $f[0] eq '副詞' and $f[1] eq '助詞類接続') {
                push @r, 'キッチリ';
            } elsif ($s eq 'きちんと' and $f[0] eq '副詞' and $f[1] eq '一般') {
                push @r, 'キッチリ';
            } elsif ($f[0] eq '副詞' and $f[1] eq '一般') {
                push @r, "$s！";
            } elsif ($s eq 'れる' and $f[0] eq '動詞' and $f[1] eq '接尾') {
                push @r, "れる゛";
            } elsif ($s eq 'として' and $f[0] eq '助詞' and $f[1] eq '格助詞' and $f[2] eq '連語') {
                if ($f_[0] eq '助詞') {
                    push @r, $s;
                } else {
                    push @r, 'として！';
                }
            } elsif ($s eq 'と' and $f[0] eq '助詞' and $f[1] eq '接続助詞' and $f_[0] ne '助詞') {
                push @r, 'と！';
            } elsif ($s eq 'と' and $f[0] eq '助詞' and $f[1] eq '接続助詞' and $f_[0] ne '助詞') {
                push @r, 'と！';
            } elsif ($s eq 'て' and $f[0] eq '助詞' and $f[1] eq '接続助詞' and $f_[0] ne '助詞') {
                my $mod = $count % 7;
                push @r, $mod == 0 ? 'デーーヒィッフウ！！　ア゛ーハーア゛ァッハアァーー！　ッグ、ッグ、ア゛ーア゛ァアァアァ'
                       : $mod == 1 ? 'ア゛ーア゛ーッハア゛ーーン！'
                       : $mod == 2 ? 'でイェーヒッフア゛ーー！！！　……ッウ、ック'
                       : $mod == 3 ? 'でえ！'
                       : $mod == 4 ? 'て！'
                       : $mod == 5 ? 'てウーハッフッハーン！！　ッウーン！'
                       : 'て';
            } elsif ($s eq 'だ' and $f[0] eq '助動詞' and $f[4] eq '特殊・ダ' and $f[5] eq '基本形') {
                push @r, 'や';
            } elsif ($s eq 'たい' and $f[0] eq '助動詞' and $f[4] eq '特殊・タイ' and $f[5] eq '基本形') {
                my $mod = $count % 2;
                push @r, $mod == 0 ? 'ダイ！'
                       : 'だい゛！';
            } elsif ($s eq 'です' and $f[0] eq '助動詞' and $f[4] eq '特殊・デス' and $f[5] eq '基本形' and $f_[0] ne '助詞') {

                # ですね、ですよ、ですか は、ですわよにしない
                # ね,助詞,終助詞
                # よ,助詞,終助詞
                # か,助詞,副助詞／並立助詞／終助詞
                if (!($f_[1] =~ /終助詞/)) {
                    my $mod = $count % 3;
                    push @r, $mod == 0 ? 'ですううー！！！'
                           : $mod == 1 ? 'ですわ'
                           : 'ですゥ！';
                } else {
                    push @r, $s;
                }

            } elsif ($s eq 'ます' and $f[0] eq '助動詞' and $f[4] eq '特殊・マス' and $f[5] eq '基本形' and $f_[0] ne '助詞') {
                push @r, 'ますわ';
            } elsif ($f[0] eq '名詞' and $f[1] eq '一般' and $count % 5 == 0) {
                my $mod = $count % 10;
                push @r, $mod == 0 ? "${s}ッヒョオッホーーー！！"
                       : "${s}";
            } elsif ($f[0] eq '名詞' and $f[1] eq '一般' and $f_[0] ne '助詞' and $f_[0] ne '助動詞') {
                my $mod = $count % 2;
                my $str = $s;
                if ($mod == 1) {
                    $str = sprintf "%s、%s", $s, $f[8];
                }
                if ($f[8] =~ /ャー$/) {
                    push @r, "${str}ァ！";
                } elsif ($f[8] =~ /ュー$/) {
                    push @r, "${str}ゥ！";
                } elsif ($f[8] =~ /ョー$/) {
                    push @r, "${str}ォ！";
                } elsif ($f[8] =~ /[あかさたなはまやらわ]$/) {
                    push @r, "${str}ァ！";
                } elsif ($f[8] =~ /[いきしちにひみり]$/) {
                    push @r, "${str}ィ！";
                } elsif ($f[8] =~ /[うくすつぬふむゆる]$/) {
                    push @r, "${str}ゥ！";
                } elsif ($f[8] =~ /[えけせてねへめれ]$/) {
                    push @r, "${str}ェ！";
                } elsif ($f[8] =~ /[おこそとのほもよろ]$/) {
                    push @r, "${str}ォ！";
                } else {
                    push @r, "${str}！";
                }
            } elsif ($f[0] eq '記号' and $f[1] eq '読点') {
                my $mod = $count % 10;
                push @r, $mod == 0 ? '、……'
                       : $mod == 1 ? '、ウェエ、'
                       : $mod == 2 ? '　ウーハッフッハーン！！　ッウーン！　'
                       : '、';
            } elsif ($f[0] eq '記号' and $f[1] eq '句点') {
                my $mod = $count % 10;
                push @r, $mod == 0 ? '……ッウ、ック。'
                       : $mod == 1 ? 'ィヒーフーッハゥ！'
                       : $mod == 2 ? '。ア゛ーー'
                       : '。';
            } else {
                push @r, $s;
            }
        }
    }

    # 句読点と感嘆符が重なったら消す
    my  $msg =  join '', @r;
    $msg =~ s/！。/！/g;
    $msg =~ s/！、/！/g;
    return $msg;
}
1;
