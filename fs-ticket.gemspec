Gem::Specification.new do |s|
    s.name          = 'fs-ticket'
    s.version       = '0.0.0'
    s.date          = '2015-12-02'
    s.summary       = 'Ncurses interface to tickets stored in a fossil-scm repo'
    s.description   = <<-END
fs-ticket is a command line interface to issues/tickets stored in a fossil
repository with a design influienced by mutt.
This tool supports basic operations such as adding, editing, searching, and
viewing tickets in the terminal.
END
    s.authors       = ["Mark McCurry"]
    s.email         = 'mark.d.mccurry@gmail.com'
    s.executables  << 'fs-ticket'
    s.files         = Dir['lib/**/*'] + [
        'bin/fs-ticket',
        'LICENSE.txt'
    ]
    s.homepage      = 'http://rubygems.org/gems/fs-ticket'
    s.license       = 'MIT'
    s.add_runtime_dependency('curses', '~>1.0')
    s.add_runtime_dependency('sqlite3', '~>1.3')
end
