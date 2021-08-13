unit role DevAssist::Skeleton;

has IO:D $.directory is required;

method spurt(::?CLASS:D: --> Bool:D) {...}

submethod TWEAK() { say "qwe" }