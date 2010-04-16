# `E` is a very-very-very basic templating engine.
#
# Example:
#     E div(class="wrapper",
#         E span("I'm wrapped, yay!"),
#         E br
#     )
#
#     ==> <div class="wrapper"><span>I'm wrapped, yay!</span><br /></div>
#
# TODO:
#   * pretty printing
#   * element validation (is it needed?)
#   * more structure manipulation methods (probably when there will be
#     more usecases availible)

ESelfClosingTags := List with(
    "br", "hr", "input", "img", "meta", "rel", "spacer",
    "link", "frame", "base"
)

E := Object clone do(
    init := method(
        self tag   ::= nil
        self inner := list()
        self attrs := Map clone
    )

    add := method(
        # Add new element to the inner element list.
        call delegateToMethod(self inner, "append")
        self
    )

    insert := method(
        # Insert new element into the last element in the inner element list.
        call delegateToMethod(self inner last, "add")
        self
    )

    asString := method(
        attrs := if(attrs size > 0,
            attrs map(attr, value,
                "#{attr}=\"#{value}\"" interpolate
            ) join(" ") prependSeq(" ")
        ,
            "")

        # It would be nice to have customizable pretty printing:
        # <tag>
        #   <tag>
        #     Text
        #   </tag>
        # </tag>
        if(tag in(ESelfClosingTags),
            "<#{self tag}#{attrs} />"
        ,
            "<#{self tag}#{attrs}>#{self inner join}</#{self tag}>"
        ) interpolate
    )

    forward := method(
        tag := self clone setTag(call message name)
        call message arguments foreach(expression,
            # If the subexpression is a tag (E <tag>(...)), append it to the
            # tag's inner list ...
            if(expression name == "E",
                tag inner append(self doMessage(expression, call sender))
            ,
                # ... else, we check the total number of arguemnts, if it's
                # equal to two, we assume the expression is of form <attr>=<value>,
                # split it accordingly and put into the tag's attr map ...
                if(expression argCount == 2,
                    tag attrs performWithArgList("atPut",
                        expression argsEvaluatedIn(call sender)
                    )
                ,
                    # ... else, the expression is treated as a text node, i.e.
                    # appended to the tag's inner list, just like a normal
                    # tag object.
                    tag inner append(expression doInContext(call sender))
                )
            )
        )
        tag
    )
)