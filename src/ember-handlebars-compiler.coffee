# https://gist.github.com/2013669

module.exports = ((emberTemplateCompiler) ->

  fs      = require 'fs'
  vm      = require 'vm'
  sysPath = require 'path'
  logger  = require 'loggy'

  if not emberTemplateCompiler?
    emberTemplateCompiler = '../../bower_components/ember/ember-template-compiler.js'

  compilerPath = sysPath.join __dirname, '..', emberTemplateCompiler

  logger.info "Using compiler: #{compilerPath}"
  compilerjs   = fs.readFileSync compilerPath, 'utf8'

  # dummy DOM element
  element =
    firstChild: -> element
    innerHTML: -> element

  sandbox =
    # DOM
    document:
      createRange: false
      createElement: -> element

    # ember 1.13 requires a navigator object
    navigator:
      userAgent: "Brunch (precompile)"

    # Console
    console: console

    # handlebars template to compile
    template: null

    # compiled handlebars template
    templatejs: null

    # container for exports, needed to support commonJS modules
    exports:
      precompile: null

  # window
  sandbox.window = sandbox

  # create a context for the vm using the sandbox data
  context = vm.createContext sandbox

  context.module = {}
  # load ember-template-compiler in the vm to compile templates
  vm.runInContext compilerjs, context, 'compiler.js'

  context.precompile = context.module.exports.precompile
  delete context.module

  return (templateData)->

    context.template = templateData

    # compile the handlebars template inside the vm context
    vm.runInContext 'templatejs = precompile(template).toString();', context

    context.templatejs;
)
