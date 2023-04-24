---
--- RPX PoliceJob by Sinatra#0101
--- The RPX framework and its resources are still under heavy development.
--- Bugs and missing features are expected.
---

RPX = exports['rpx-core']:GetObject()

do
    require 'shared.config'

    if IsDuplicityVersion() then
        -- Server Modules
        require 'server'
        require 'modules.coachmenu.server'
    else
        -- Client Modules
        require 'client'
        require 'modules.coachmenu.client'
    end
end