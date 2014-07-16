#!/usr/bin/env perl
use Mojolicious::Lite;
use URI::Escape::XS;
use Gokyu;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

app->config(hypnotoad => {listen => ['http://*:3000'], workers => 20});

get '/kengi' => sub {
  my $c = shift;
  $c->render('index', result => '', enc => '');
};

post '/kengi' => sub {
  my $c = shift;
  $c->app->log->info($c->param('message'));
  my $text = conv($c->param('message'));
  $c->render('index', result => $text, enc => encodeURIComponent($text));
};

app->start;
__DATA__

@@ not_found.html.ep
% layout 'default';
% title 'Not found';
      <div class="starter-template">
        <h1>Not found</h1>
      </div>

@@ index.html.ep
% layout 'default';
% title '号泣県議コンバーター';
      <div class="starter-template">
        <h1>号泣県議コンバーター</h1>

        <a href="https://twitter.com/intent/tweet?button_hashtag=%E5%8F%B7%E6%B3%A3%E7%9C%8C%E8%AD%B0%E3%82%B3%E3%83%B3%E3%83%90%E3%83%BC%E3%82%BF%E3%83%BC&text=<%= $enc %>" class="twitter-hashtag-button">Tweet #%E5%8F%B7%E6%B3%A3%E7%9C%8C%E8%AD%B0%E3%82%B3%E3%83%B3%E3%83%90%E3%83%BC%E3%82%BF%E3%83%BC</a>
        <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>

        <p class="lead"><%= $result %></p>
        <%= form_for '/kengi' => (method => 'post') => begin %>
          <%= text_area 'message', class => 'form-control input-lg', rows => "3", placeholder => "文章を入力してください(2000文字まで)", maxlength => "2000" %><br>
          <%= submit_button 'あ゛ぁぁー', class => "btn btn-primary btn-lg" %>
        <% end %>
        <br>
        <small>サンプル</small>
        <br>
        <small>こんな大人で、県民の皆さま、私も死ぬ思いで、もう死ぬ思いでもう、あれですわ。一生懸命、落選に落選を重ねて、見知らぬ西宮市に移り住んで、やっと県民の皆様に認められて選出された代表者たる議員であるからこそ、こうやって報道機関の皆さまにご指摘を受けるのが、本当にツラくって、情けなくって、子ども達に本当に申し訳ないんですわ。</small>
      </div>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title><%= title %></title>
    <link href="//maxcdn.bootstrapcdn.com/bootswatch/3.2.0/flatly/bootstrap.min.css" rel="stylesheet">
    <%= stylesheet begin %>
      body {
        padding-top: 50px;
      }
      .starter-template {
        padding: 40px 15px;
        text-align: center;
      }
    <% end %>
  </head>
  <body>
    <div class="container">
      <%= content %>
    </div><!-- /.container -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
  </body>
</html>
