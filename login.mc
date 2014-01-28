<%args>
 $username => undef
 $password => ''
 $login => 0
 $logout => 0
</%args>

<%init>
    my $dbh = $dbx{'test'};
    
    if ($login) {
        #code
        $dbh->select(
            {
                fields => "username, password",
                tables => "group2_user",
                where  => { username => $username }
            }
        );
        my $res = $dbh->fetchrow_hashref();
        
        if (defined($res->{username})) {
            #check pw
            print $password ." " . $res->{password};
            if ( $password eq $res->{password} ) {
                #code
                $session{logged_in} = 1;
                $session{user} = $username;
                $session{login_error_msg} = "";
                $m->redirect('index.mc');

            } else {
                $session{login_error_msg} = "ERROR Wrong user details provided.";
                $m->redirect('index.mc');
            }
            
        } else {
            $session{login_error_msg} = "ERROR Wrong user details provided.";
            $m->redirect('index.mc');
        }
    }
    if ($logout) {
        #code
        $session{logged_in} = 0;
        $session{user} = "";
        $session{login_error_msg} = "";
        $m->redirect('index.mc');
    }
</%init>