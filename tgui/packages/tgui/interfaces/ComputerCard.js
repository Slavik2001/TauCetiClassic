import { Fragment } from "inferno";
import { useLocalState, useBackend } from "../backend";
import { NoticeBox, Button, LabeledList, Section, Tabs } from "../components";
import { Window } from "../layouts";
import { AccessList } from './common/AccessList';
import { CrewManifest } from "./common/CrewManifest";

export const ComputerCard = (props, context) => {
  const { act, data } = useBackend(context);
  const [mode, setMode] = useLocalState(context, 'mode', data.mode);
  const ChangeMode = (mode) => {
    setMode(mode);
    act("mode", { mode });
  };

  if (mode !== data.mode) {
    setMode(data.mode);
  }

  const menuBlock = (
    <Tabs>
      <Tabs.Tab
        icon="id-card"
        selected={mode === 0}
        onClick={() => ChangeMode(0)}>
        Access Modification
      </Tabs.Tab>
      <Tabs.Tab
        icon="folder-open"
        selected={mode === 1}
        onClick={() => ChangeMode(1)}>
        Crew Manifest
      </Tabs.Tab>
      <Tabs.Tab
        icon="scroll"
        selected={mode === 2}
        onClick={() => {
          act("print");
          ChangeMode(2);
        }}>
        Print
      </Tabs.Tab>
    </Tabs>
  );

  const authBlock = (
    <Section title="Authentication">
      <LabeledList>
        <LabeledList.Item label="Target Identity">
          <Button
            icon={data.modify_name ? 'eject' : 'id-card'}
            selected={data.modify_name}
            content={data.modify_name ? data.modify_name : "-----"}
            tooltip={data.modify_name ? "Eject ID" : "Insert ID"}
            onClick={() => act("modify")} />
        </LabeledList.Item>
        <LabeledList.Item label="Authorized Identity">
          <Button
            icon={data.scan_name ? 'eject' : 'id-card'}
            selected={data.scan_name}
            content={data.scan_name ? data.scan_name : "-----"}
            tooltip={data.scan_name ? "Eject ID" : "Insert ID"}
            onClick={() => act("scan")} />
        </LabeledList.Item>
        <LabeledList.Item label="Registered Name">
          <Button
            icon={!data.modify_owner || data.modify_owner === "Unknown" ? "exclamation-triangle" : "pencil-alt"}
            selected={data.modify_name}
            content={data.modify_owner}
            onClick={() => act("reg")} />
        </LabeledList.Item>
        <LabeledList.Item label="Account Number">
          <Button
            icon={data.account_number ? "pencil-alt" : "exclamation-triangle"}
            selected={data.account_number}
            content={data.account_number ? data.account_number : "None"}
            onClick={() => act("account")} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );

  let bodyBlock;
  switch (mode) {
    case 0: // Access Modification
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = (
          <NoticeBox title="Warning" color="red">
            Not logged in.
          </NoticeBox>
        );
      } else if (!data.modify_name) {
        bodyBlock = (
          <NoticeBox title="Card Missing" color="red">
            No card to modify.
          </NoticeBox>
        );
      } else {
        bodyBlock = (
          <Fragment>
            <Section title="Department">
              <LabeledList>
                <LabeledList.Item label="Command">
                  {data.command_jobs.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      onClick={() => act("assign", { assign_modify: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="NT Representatives">
                  {data.nt_representatives.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      onClick={() => act("assign", { assign_modify: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Engineering">
                  {data.engineering_jobs.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      onClick={() => act("assign", { assign_modify: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Medical">
                  {data.medical_jobs.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      onClick={() => act("assign", { assign_modify: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Science">
                  {data.science_jobs.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      onClick={() => act("assign", { assign_modify: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Security">
                  {data.security_jobs.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      onClick={() => act("assign", { assign_modify: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Civilian">
                  {data.civilian_jobs.map(v => (
                    <Button
                      selected={v === data.modify_rank}
                      key={v} content={v}
                      onClick={() => act("assign", { assign_modify: v })} />
                  ))}
                </LabeledList.Item>
                <LabeledList.Item label="Custom">
                  <Button label="Custom"
                    key="Custom" content="Custom"
                    onClick={() => act("assign", { assign_modify: "Custom" })} />
                </LabeledList.Item>
                {!!data.centcom_access && (
                  <LabeledList.Item label="CentCom">
                    {data.centcom_jobs.map(v => (
                      <Button
                        selected={v === data.modify_rank}
                        key={v} content={v}
                        onClick={() => act("assign", { assign_modify: v })} />
                    ))}
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Demotions">
                  <Button
                    disabled={"Demoted" === data.modify_rank}
                    key="Demoted" content="Demoted"
                    tooltip="Civilian access, 'demoted' title."
                    color="red" icon="times"
                    onClick={() => act("demote")} />
                </LabeledList.Item>
                <LabeledList.Item label="Non-Crew">
                  <Button
                    disabled={"Terminated" === data.modify_rank}
                    key="Terminate" content="Terminated"
                    tooltip="Zero access. Not crew."
                    color="red" icon="eraser"
                    onClick={() => act("terminate")} />
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section>
              <AccessList
                isCompCard
                fast_modify_region={data.fast_modify_region}
                fast_full_access={data.fast_full_access}
                accesses={data.regions}
                selectedList={data.selectedAccess}
                accessMod={ref => act('access', { access: ref })}
                grantAll={() => act('access_full')}
                denyAll={() => act('clear_all')}
                grantDep={ref => act('access_region', { region: ref })}
                denyDep={ref => act('deny_region', { region: ref })} />
            </Section>
          </Fragment>
        );
      }
      break;

    case 1: // Crew Manifest
      bodyBlock = <CrewManifest manifest={data.manifest} />;
      break;

    case 2: // Print
      if (data.printing) {
        bodyBlock = (
          <NoticeBox title="Warning" color="blue">
            Printing... The computer is currently busy. Thank you for your patience!
          </NoticeBox>
        );
      }
      break;

    default:
      bodyBlock = (
        <NoticeBox title="Warning" color="red">
          ERROR: Unknown Mode.
        </NoticeBox>
      );
      break;
  }

  return (
    <Window width={925} height={850} resizable>
      <Window.Content scrollable>
        <Section
          title="Card Modification"
          buttons={menuBlock}>
          {authBlock}
          {bodyBlock}
        </Section>
      </Window.Content>
    </Window>
  );
};
