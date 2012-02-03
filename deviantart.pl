use Dancer;
use Net::OAuth2::Client;
use HTTP::Request::Common;

sub client {
    Net::OAuth2::Client->new(
        '0', # OAuth 2.0 client_id
        '1234567890abcdef', # OAuth 2.0 client_secret
        site => 'http://www.deviantart.com',
        authorize_path => 'https://www.deviantart.com/oauth2/draft15/authorize?response_type=code',
        access_token_path => 'https://www.deviantart.com/oauth2/draft15/token?grant_type=authorization_code',
        access_token_method => 'GET',
    )->web_server(
        redirect_uri => uri_for('/auth/deviantart/callback')
    );
}

get '/auth/deviantart' => sub {
    redirect client->authorize_url;
};

get '/auth/deviantart/callback' => sub {
    my $access_token = client->get_access_token(params->{code});
    
    my $headers = HTTP::Headers->new(Content_Type => 'form-data');
    
    my $request = POST '',
        Content_Type => 'form-data',
        Content      => [title => 'Perl Fella', file => ['./fella.png']];
    
    my $response = $access_token->post('/api/draft15/stash/submit', $request->headers, $request->content);
    
    if ($response->is_success) {
        return "Great success: " . $response->decoded_content;
    } else {
        return "Error: " . $response->status_line;
    }
};

dance;