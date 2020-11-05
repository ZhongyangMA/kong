local helpers = require "spec.helpers"

describe("kong quit", function()
  lazy_setup(function()
    helpers.get_db_utils(nil, {}) -- runs migrations
    helpers.prepare_prefix()
  end)
  after_each(function()
    helpers.kill_all()
  end)
  lazy_teardown(function()
    helpers.clean_prefix()
  end)

  it("quit help", function()
    local _, stderr = helpers.kong_exec "quit --help"
    assert.not_equal("", stderr)
  end)
  it("quits gracefully", function()
    assert(helpers.kong_exec("start --conf " .. helpers.test_conf_path))
    assert(helpers.kong_exec("quit --prefix " .. helpers.test_conf.prefix))
  end)
  it("quit gracefully with --timeout option", function()
    assert(helpers.kong_exec("start --conf " .. helpers.test_conf_path))
    assert(helpers.kong_exec("quit --timeout 2 --prefix " .. helpers.test_conf.prefix))
  end)
  it("quit gracefully with --wait option", function()
    assert(helpers.kong_exec("start --conf " .. helpers.test_conf_path))
    ngx.update_time()
    local start = ngx.now()
    assert(helpers.kong_exec("quit --wait 2 --prefix " .. helpers.test_conf.prefix))
    ngx.update_time()
    local duration = ngx.now() - start
    assert.is.near(2, duration, 1.8)
  end)
end)
