use DevAssist::Skeleton;
unit class DevAssist::Skeleton::Raku does DevAssist::Skeleton;

use META6;

has Str:D $.name is required;
has IO:D() @.bin;

has Str:D $.fullname = %*ENV<DEBFULLNAME> // %*ENV<FULLNAME>;
has Str:D $.username = %*ENV<LOGNAME> // %*ENV<USER> // $*USER;
has Str:D $.email = %*ENV<DEBEMAIL> // %*ENV<EMAIL>;

method spurt(::?CLASS:D: --> Bool:D) {
    $!directory.mkdir;
    $!directory.add('t').mkdir;
    $!directory.add('xt').mkdir;
    $!directory.add('bin').mkdir;
    $!directory.add('lib').mkdir;
    $!directory.add('resources').mkdir;
    $!directory.add('logotype').mkdir;
    $!directory.add('examples').mkdir;
    $!directory.add('doc').mkdir;
    my Bool:D $res = True;
    $res &&= self.spurt-meta;
    $res &&= self.spurt-t-sanaty;
    $res &&= self.spurt-xt-meta;
    $res &&= self.spurt-bin: $_ for @!bin;
    $res &&= self.spurt-lib;
    $res &&= self.spurt-resources-toRemove;
    $res &&= self.spurt-logotype-toRemove;
    $res &&= self.spurt-build;
    $res &&= self.spurt-examples-sample;
    $res &&= self.spurt-NEWS;
    $res &&= self.spurt-LICENSE;
    $res &&= self.spurt-README;
    $res &&= self.spurt-CONTRIBUTING;
    $res &&= self.spurt-CODE_OF_CONDUCT;
    $res &&= self.spurt-github-ISSUE_TEMPLATE-bug_report;
    $res &&= self.spurt-github-ISSUE_TEMPLATE-feature_request;
    $res &&= self.spurt-github-FUNDING;
    $res &&= self.spurt-gitignore;
    $res &&= so run <git init>, $!directory;
    $res;
}
method spurt-meta(::?CLASS:D: --> Bool:D) {
    $!directory.add('META6.json').spurt: META6.new(
            :$!name,
            version => v0.0.1,
            auth => $!username,
            description => 'Write me!',
            raku-version => v6.*,
            depends => {
                runtime => {
                    requires => [
                        ['JSON::Fast', 'JSON::Tiny'],
                        'JSON::Class:ver(v0.1 .. v0.5)'
                    ],
                    recommends => [
                        {
                            name => 'JSON::Pretty',
                        },
                        'curl:from<bin>',
                        'curl:from<native>',
                    ],
                }
            },
            test-depends => ['Test', 'Test::META:ver<0.0.17+>'],
            build-depends => [],
            tags => [],
            authors => ["$!fullname <$!email>"],
            source-url => 'Write me!',
            support => META6::Support.new(
                    source => 'Write me!',
                    ),
            provides => {
                $!name => $!directory.add('lib').add($!name.split("::").join('/')).extension("rakumod", :0parts).Str,
            },
            license => 'Write me!',
            ).to-json: :sorted-keys;
}
method spurt-t-sanaty(::?CLASS:D: --> Bool:D) {
    $!directory.add('t').add('00-sanity.rakutest').spurt: qq:to/END/;
use Test;
plan 1;
use-ok { $!name.raku };
done-testing;
END

}
method spurt-xt-meta(::?CLASS:D: --> Bool:D) {
    $!directory.add('xt').add('00-meta.rakutest').spurt: qq:to/END/;
use Test;
use Test::META;
plan 1;
meta-ok;
done-testing;
END

}
method spurt-examples-sample(::?CLASS:D: --> Bool:D) {
    $!directory.add('examples').add('00-sample.raku').spurt: qq:to/END/;
use $!name;
END

}
method spurt-bin(::?CLASS:D: IO:D $fname --> Bool:D) {
    $!directory.add('bin').add($fname).spurt: qq:to/END/;
#!/usr/bin/raku
use tmp;
END
}

method spurt-lib(::?CLASS:D: --> Bool:D) {
    my $file = $!directory.add('lib').add($!name.split("::").join('/')).extension("rakumod", :0parts);
    $file.parent.mkdir;
    $file.spurt: qq:to/END/;
unit module $!name;
END

}

method spurt-resources-toRemove(::?CLASS:D: --> Bool:D) {
    $!directory.add('resources').add('toRemove.txt').spurt: qq:to/END/;
Place here resource file, you can access it by \%?RESOURCES<file/name>.
When you don't install module, you can access by pass the META6.json path to -I raku option
eg: raku -I. bin/my-script
END

}

method spurt-logotype-toRemove(::?CLASS:D: --> Bool:D) {
    $!directory.add('logotype').add('toRemove.txt').spurt: qq:to/END/;
Place here a logo for your module. eg: logotype/logo_32x32.png
END

}
method spurt-build(::?CLASS:D: --> Bool:D) {
    # raku -I . -M Build -e 'Build.new.build(".")'
    $!directory.add('Build.rakumod').spurt: q:to/END/;
class Build {
    method build(IO:D() $module-directory) {
        ...
    }
}
END

}
method spurt-NEWS(::?CLASS:D: --> Bool:D) {
    $!directory.add('NEWS.md').spurt: qq:to/END/;
$!name NEWS

# Noteworthy changes in release ?.? (????-??-??) [devel]
## Deprecated features
## New features
## Changes
## Documentation
## Bug Fixes
END

}
method spurt-LICENSE(::?CLASS:D: --> Bool:D) {
    $!directory.add('LICENSE').spurt: qq:to/END/;
END

}
method spurt-README(::?CLASS:D: --> Bool:D) {
    $!directory.add('README.md').spurt: qq:to/END/;
# $!name
END

}
method spurt-CONTRIBUTING(::?CLASS:D: --> Bool:D) {
    $!directory.add('CONTRIBUTING.md').spurt: qq:to/END/;
# Contributing to $!name
END

}
method spurt-CODE_OF_CONDUCT(::?CLASS:D: --> Bool:D) {
    $!directory.add('CODE_OF_CONDUCT.md').spurt: qq:to/END/;
END

}
method spurt-github-ISSUE_TEMPLATE-bug_report(::?CLASS:D: --> Bool:D) {
    my IO:D $file = $!directory.add('.github').add('ISSUE_TEMPLATE').add('bug_report.md');
    my $res = $file.parent.mkdir;
    $res &&= $file.spurt: qq:to/END/;
END

    $res;
}
method spurt-github-ISSUE_TEMPLATE-feature_request(::?CLASS:D: --> Bool:D) {
    my IO:D $file = $!directory.add('.github').add('ISSUE_TEMPLATE').add('feature_request.md');
    my $res = $file.parent.mkdir;
    $res &&= $file.spurt: qq:to/END/;
END

    $res;
}
method spurt-github-FUNDING(::?CLASS:D: --> Bool:D) {
    my IO:D $file = $!directory.add('.github').add('FUNDING.yml');
    my $res = $file.parent.mkdir;
    $res &&= $file.spurt: qq:to/END/;
# These are supported funding model platforms

github: # Replace with up to 4 GitHub Sponsors-enabled usernames e.g., [user1, user2]
patreon: # Replace with a single Patreon username
open_collective: # Replace with a single Open Collective username
ko_fi: # Replace with a single Ko-fi username
tidelift: # Replace with a single Tidelift platform-name/package-name e.g., npm/babel
community_bridge: # Replace with a single Community Bridge project-name e.g., cloud-foundry
liberapay: # Replace with a single Liberapay username
issuehunt: # Replace with a single IssueHunt username
otechie: # Replace with a single Otechie username
custom: # Replace with up to 4 custom sponsorship URLs e.g., ['link1', 'link2']
END

    $res;
}
method spurt-gitignore(::?CLASS:D: --> Bool:D) {
    $!directory.add('.gitignore').spurt: qq:to/END/;
.precomp
lib/.precomp
END

}



submethod TWEAK() {
    say "plm"
}