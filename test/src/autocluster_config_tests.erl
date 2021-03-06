-module(autocluster_config_tests).

-include_lib("eunit/include/eunit.hrl").


get_test_() ->
  {
    foreach,
    fun autocluster_testing:on_start/0,
    fun autocluster_testing:on_finish/1,
    [
      {
        "invalid value",
        fun() ->
          ?assertEqual(undefined, autocluster_config:get(invalid_config_key))
        end
      }
    ]
  }.


app_envvar_test_() ->
  {
    foreach,
    fun autocluster_testing:on_start/0,
    fun autocluster_testing:on_finish/1,
    [
      {
        "app atom value",
        fun() ->
          application:set_env(autocluster, longname, true),
          ?assertEqual(true, autocluster_config:get(longname))
        end
      },
      {
        "app integer value",
        fun() ->
          application:set_env(autocluster, consul_port, 8502),
          ?assertEqual(8502, autocluster_config:get(consul_port))
        end
      },
      {
        "app string value",
        fun() ->
          application:set_env(autocluster, consul_svc, "rabbit"),
          ?assertEqual("rabbit", autocluster_config:get(consul_svc))
        end
      },
      {
        "app string value when binary",
        fun() ->
          application:set_env(autocluster, consul_svc, <<"rabbit">>),
          ?assertEqual("rabbit", autocluster_config:get(consul_svc))
        end
      },
      {
        "app list value when string",
        fun() ->
          application:set_env(autocluster, proxy_exclusions, "foo,42,42.5"),
          ?assertEqual(["foo", 42, 42.5], autocluster_config:get(proxy_exclusions))
        end
      },
      {
        "consul tags",
        fun() ->
          application:set_env(autocluster, consul_svc_tags, "urlprefix-:5672 proto=tcp, mq, mq server"),
          ?assertEqual(["urlprefix-:5672 proto=tcp","mq","mq server"], autocluster_config:get(consul_svc_tags))
        end
      }
    ]
  }.


os_envvar_test_() ->
  {
    foreach,
    fun autocluster_testing:on_start/0,
    fun autocluster_testing:on_finish/1,
    [
      {
        "os atom value",
        fun() ->
          os:putenv("RABBITMQ_USE_LONGNAME", "true"),
          ?assertEqual(true, autocluster_config:get(longname))
        end
      },
      {
        "os integer value",
        fun() ->
          os:putenv("CONSUL_PORT", "8501"),
          ?assertEqual(8501, autocluster_config:get(consul_port))
        end
      },
      {
        "prefixed envvar",
        fun() ->
          os:putenv("RABBITMQ_USE_LONGNAME", "true"),
          os:putenv("USE_LONGNAME", "false"),
          ?assertEqual(true, autocluster_config:get(longname))
        end
      },
      {
        "no prefixed envvar",
        fun() ->
          os:putenv("USE_LONGNAME", "true"),
          ?assertEqual(true, autocluster_config:get(longname))
        end
      },
      {
        "docker changing CONSUL_PORT value",
        fun() ->
          os:putenv("CONSUL_PORT", "tcp://172.17.10.3:8501"),
          ?assertEqual(8501, autocluster_config:get(consul_port))
        end
      },
      {
        "aws tags",
        fun() ->
          os:putenv("AWS_EC2_TAGS",
                    "{\"region\": \"us-west-2\",\"service\": \"rabbitmq\"}"),
          ?assertEqual([{"region", "us-west-2"}, {"service", "rabbitmq"}],
                       autocluster_config:get(aws_ec2_tags))
        end
      },
      {
        "proxy exclusions",
        fun() ->
          os:putenv("PROXY_EXCLUSIONS", "foo,42,42.5"),
          ?assertEqual(["foo", 42, 42.5], autocluster_config:get(proxy_exclusions))
        end
      },
      {
        "consul tags set",
        fun() ->
          os:putenv("CONSUL_SVC_TAGS", "urlprefix-:5672 proto=tcp, mq, mq server"),
          ?assertEqual(["urlprefix-:5672 proto=tcp","mq","mq server"], autocluster_config:get(consul_svc_tags))
        end
      },
      {
        "consul tags unset",
        fun() ->
          ?assertEqual([], autocluster_config:get(consul_svc_tags))
        end
      }
    ]
  }.
