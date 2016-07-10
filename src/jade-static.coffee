path = require 'path'
fs = require 'fs'
jade = require 'jade'


readAndSendTemplate = (d, options, res, next) ->

    # Read the jade file.
    fs.readFile d, 'utf8', (err, data) ->

        # Anything screws up, then move on.
        if err?
            return next()

        try
            unless options?
                options = filename: d
            else
                options.filename = d

            template = jade.compile data, options
            html = template {}
            res.send html, 'Content-Type': 'text/html', 200
        catch err
            next err


checkFileAndProcess = (d, options, res, next) ->

    # Check if file is exists
    fs.lstat d, (err, stats) ->

        # If it exists, then we got ourselves a jade file.
        if not err? and stats.isFile()
            readAndSendTemplate d, options, res, next
        else
            next()


module.exports = (options) ->
    if not options?
        throw new Error("A path must be specified.")

    if typeof options is 'string'
        options = src: options, html: true

    if typeof options.html is 'undefined'
        options.html = true

    # The actual middleware itself.
    return (req, res, next) ->

        # The inputed url relative to the path.
        d = path.join options.src, req.url.split('?')[0]

        # Determines what d is.
        fs.lstat d, (err, stats) ->

            # is it a directory?
            if not err? and stats.isDirectory()

                # If so, check if there is exists a file called index.jade.
                checkFileAndProcess "#{d}/index.jade", options.jade, res, next

            else if not err? and stats.isFile() and path.extname(d) is '.jade'
                readAndSendTemplate d, options.jade, res, next
                
            # try to replace html file by jade template
            else if options.html? and path.extname(d) is '.html'

                # check template exists
                checkFileAndProcess d.replace(/html$/, 'jade'), options.jade, res, next
            else
                next()
