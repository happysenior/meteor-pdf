testRoot = '/packages/pdf.js'
pdfFilename = 'pdf.js/web/compressed.tracemonkey-pldi-09.pdf'

Tinytest.addAsync 'pdf.js - general', (test, onComplete) ->
  isDefined = false
  try
    PDFJS
    isDefined = true

  test.isTrue isDefined, "PDFJS is not defined"
  test.isTrue Package['pdf.js'].PDFJS, "Package.pdf.js.PDFJS is not defined"

  if Meteor.isClient
    # Random query parameter to prevent caching
    pdf = "#{ testRoot }/#{ pdfFilename }?#{ Random.id() }"
  else
    pdf =
      data: Assets.getBinary pdfFilename
      password: ''

    document = PDFJS.getDocumentSync(pdf)
    test.equal document.numPages, 14
    page = document.getPageSync 1
    test.equal page.pageNumber, 1
    test.length page.getAnnotationsSync(), 0

    test.throws ->
      document.getPageSync 15
    , /Page index 14 not found/

  processPDF = (document) ->
    test.equal document.numPages, 14
    onComplete()

  error = (message, exception) ->
    if exception
      test.exception exception
    else
      test.fail
        type: "error"
        message: message
      onComplete()

  processPDF = Meteor.bindEnvironment processPDF, (e) -> test.exception e, this
  error = Meteor.bindEnvironment error, (e) -> test.exception e, this

  PDFJS.getDocument(pdf).then processPDF, error
