import defaultComponents from "fumadocs-ui/mdx";
import { Tabs, Tab } from "fumadocs-ui/components/tabs";
import type { MDXComponents } from "mdx/types";
import { CodeBlock, Pre } from "fumadocs-ui/components/codeblock";

export function getMDXComponents(components?: MDXComponents): MDXComponents {
    return {
        ...defaultComponents,
        pre: ({ ref: _ref, ...props }) => (
            <CodeBlock {...props}>
                <Pre>{props.children}</Pre>
            </CodeBlock>
        ),
        img: ({ src, ...props }) => {
            const basePath = process.env.NEXT_PUBLIC_BASE_PATH || "";
            const source =
                typeof src === "string" && src.startsWith("/")
                    ? `${basePath}${src}`
                    : src;

            return <img src={source} {...props} />;
        },
        Tabs,
        Tab,
        ...components,
    };
}
