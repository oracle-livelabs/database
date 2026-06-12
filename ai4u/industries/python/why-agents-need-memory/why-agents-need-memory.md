# Why Agents Need Memory

## Introduction

Everything you've built so far has a fatal flaw: **the agent forgets everything between sessions**.

In this lab, you'll experience the problem firsthand. You'll tell an agent important client details — contact preferences, rate exceptions, relationship history — and then start a new session. Everything is gone. The agent has no idea who Sarah Chen is or what you told it five minutes ago.

This is exactly what's happening at Seer Equity right now.

### The Business Problem

Last month, a loan officer at Seer Equity quoted standard rates to Sarah Chen — a client who's been with the company for six years and has a 15% rate exception on file. Sarah was not happy. She'd told three different loan officers about her preferences, and none of them remembered.

The problem isn't the people. It's the technology. Every conversation starts fresh. There's no persistent memory. The agent is stateless.

> *"I've told three different people that I prefer email. I've told two of them about my rate exception. Why does nobody remember?"*
>
> Sarah Chen, frustrated Seer Equity client

**Estimated Time**: 10 minutes

### Objectives

* Build a stateless agent and share important information with it
* Verify the agent remembers within a session (context window)
* Start a new session and watch everything disappear
* Understand why LLMs are inherently stateless

### Prerequisites

* Completed the **Getting Started** lab
* Jupyter Notebook running with Oracle 26ai connection verified

## Task 1: Set Up the Notebook

1. Create a new Jupyter notebook for this lab.

2. Run the shared setup code.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    import oracledb
    import os
    from langchain_openai import ChatOpenAI
    from langchain_core.tools import tool
    from langgraph.prebuilt import create_react_agent

    conn = oracledb.connect(
        user=os.getenv("ORACLE_USER", "AGENT_USER"),
        password=os.getenv("ORACLE_PASSWORD"),
        dsn=os.getenv("ORACLE_DSN", "localhost:1521/FREEPDB1"),
    )
    print(f"Connected as: {conn.username}")

    llm = ChatOpenAI(
        model=os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
        temperature=0,
    )

    print("Setup complete.")
    </copy>
    ```

## Task 2: Build a Stateless Agent

This agent has a warm, relationship-focused system prompt. It *wants* to remember client preferences. But it has no memory tools — everything lives only in the conversation's message history.

1. Create the agent.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    @tool
    def basic_query(sql_text: str) -> str:
        """Run a read-only SQL query against the database."""
        try:
            with conn.cursor() as cur:
                cur.execute(sql_text)
                rows = cur.fetchall()
            if not rows:
                return "No results found."
            return "\n".join(str(r) for r in rows[:20])
        except Exception as e:
            return f"Query error: {e}"

    SYSTEM_PROMPT = """You are a loan officer assistant for Seer Equity.
    Remember any preferences or information clients share with you
    so you can serve them better. Build relationships by recalling past interactions."""

    agent = create_react_agent(
        model=llm,
        tools=[basic_query],
        prompt=SYSTEM_PROMPT,
    )

    print("Stateless agent created.")
    </copy>
    ```

## Task 3: Session 1 — Share Client Information

Tell the agent important details about Sarah Chen. Within the same session, the agent will remember because the information is still in the message history (the context window).

1. Share Sarah Chen's preferences.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    messages = [("user",
        "Sarah Chen prefers email contact, never phone. "
        "Her timezone is Pacific. She has a 15 percent rate exception "
        "that was approved last year due to her long relationship with Seer Equity. "
        "Please remember this for future interactions."
    )]

    response = agent.invoke({"messages": messages})
    print("Agent says:", response["messages"][-1].content)
    </copy>
    ```

    The agent will acknowledge that it will remember this information.

2. Verify it remembers — within the same session.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # Continue the same conversation (same message history)
    messages = response["messages"] + [("user", "What is Sarah Chen's preferred contact method?")]
    response = agent.invoke({"messages": messages})
    print("Agent says:", response["messages"][-1].content)
    </copy>
    ```

    It remembers! But only because the information is still in the message list that was passed in. The LLM is reading its own conversation history, not recalling from any stored memory.

## Task 4: Session 2 — The Forgetting Problem

Now simulate what happens when a new session starts. A new message list. A clean slate. No prior conversation history.

1. Ask the same questions with a fresh message list.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    # New session — new message list. The old conversation is gone.
    fresh_response = agent.invoke({
        "messages": [("user", "What is Sarah Chen's preferred contact method?")]
    })
    print("New session — contact preference:")
    print("Agent says:", fresh_response["messages"][-1].content)
    </copy>
    ```

    The agent has no idea. It will either say it doesn't have that information or try to offer generic advice.

2. Ask about the rate exception.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    fresh_response = agent.invoke({
        "messages": [("user", "What rate exception does Sarah Chen have?")]
    })
    print("New session — rate exception:")
    print("Agent says:", fresh_response["messages"][-1].content)
    </copy>
    ```

    Gone. All of it. The 15% rate exception, the email preference, the Pacific timezone — none of it was stored anywhere durable.

## Task 5: Understand the Impact

1. Review what just happened.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    print("""
    ┌────────────────────────┬────────────────────────────────────────────┐
    │ What's Forgotten       │ Business Impact                            │
    ├────────────────────────┼────────────────────────────────────────────┤
    │ Contact preferences    │ Wrong contact method annoys clients        │
    │ Rate exceptions        │ Long-term clients quoted wrong rates       │
    │ Relationship history   │ Every interaction starts over              │
    │ Past decisions         │ Same issues re-decided differently         │
    └────────────────────────┴────────────────────────────────────────────┘

    The LLM is stateless. Without external memory, the agent forgets
    everything between sessions. The solution: store memory in Oracle 26ai.
    """)
    </copy>
    ```

    This is the problem that drives the rest of the workshop. In the next labs, you'll build the solution — persistent memory backed by Oracle 26ai.

## Summary

You've just experienced the forgetting problem:

* **Within a session**: the agent remembers because the information is in the message history (context window).
* **Across sessions**: everything is lost. New session = clean slate.
* **The LLM is stateless**: it has no built-in memory. It can only work with what's in the current prompt.

This is why Sarah Chen gets asked for her email preference every time. This is why loan officers quote her the wrong rate. The AI doesn't remember, because nobody gave it a place to store memories.

The solution is in the next labs: **Oracle 26ai as the memory substrate**. The agent will store facts, preferences, and decisions in the database — and recall them in any future session.

You may now **proceed to the next lab**.

## Learn More

* [LangChain Memory Concepts](https://python.langchain.com/docs/concepts/memory/)
* [Why Agents Need External Memory](https://python.langchain.com/docs/concepts/persistence/)
* [Oracle Database 26ai JSON Support](https://docs.oracle.com/en/database/oracle/oracle-database/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
