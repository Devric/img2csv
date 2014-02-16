#! /usr/bin/env node

var fs    = require('fs')
    cli   = require('commander')
    async = require('async')

    option = {
        seperator : ','
      , newLine   : '\r\n'
      , header    : 'title, @image'
      , imgFormat : [
            'jpg'
          , 'jpeg'
          , 'png'
          , 'gif'
          , 'bmp'
          , 'tif'
          , 'psd'
          , 'ai'
          , 'eps'
        ]
    }

// setup commander
cli.version('0.0.1')
    .usage('/inputFolder')
    .option('-o, --output', 'custom output')
    .parse(process.argv)

// define paths
var in_path  = ( cli.args[0] || __dirname ) + '/'
  , out_path = ( cli.args[1] || __dirname ) + '/'

// write files to csv
async.waterfall([
    // get images list
    function(getImageList){
        fs.readdir(in_path, function(err, files){ 
            getImageList(err, files)
        })
    }

    // filter image list
  , function(imageList, filteredList) {
        var list = imageList.filter(matchFormat)

        filteredList(null, list)
    }

    // build csv
  , function(list, text) {
      var header = option.header + option.newLine
        , build  = []

      list.map(function(item){
          build.push(getTitle(item) + option.seperator + in_path + item)
          writeFile('cache', item)
      })
      text(null, header + build.join(option.newLine))
  }
], function(err, result){ 
    if (err) console.log(err)

    writeFile('csv', result)
})

// Helpers
function matchFormat(img) { 
    var imgFormat = option.imgFormat
      , ext = img.toString().match(/.([a-z]+)$/i)
      , len = imgFormat.length
      , i   = 0

    if (!ext) return img

    while(len) {
        if (ext[1] === imgFormat[len-1]) {
            return img
        }
        len--
    }
}

function getTitle(img) { 
    var title   = img.toString()
      , formats = option.imgFormat.join('|')
      , formats = new RegExp("\\.["+formats+"]+","gm")
      , title   = title.replace(formats, '')
      , newTitle

    title = title.split('-')
    newTitle = title[0] + '-' + title[1]
    return newTitle
}

// Write to files
function writeFile(type, data) { 
    var toFile = {
        // TODO - if prevent regenerating the whole list
        cache : function() {
                    fs.appendFile(out_path+'gen_recorded.txt', data+'|')
                }
      , csv   : function() {
                    fs.writeFile(out_path+'gen_images.csv', data)
              }
    }

    toFile[type]()
}

