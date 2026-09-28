"""Generate repository fixtures from invented values, never from production rows."""
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEEDS = ROOT / "seeds"
SEEDS.mkdir(exist_ok=True)


def write_seed(name, header, rows):
    with (SEEDS / f"{name}.csv").open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(header.split(","))
        writer.writerows(rows)


write_seed("company_name_mapping", "raw_company_name,standardized_company_name", [
    ["Demo Company A", "DemoCompanyA"], ["Demo Company B", "DemoCompanyB"], ["无", "无"]])
write_seed("company_location_mapping", "company_name,province,city", [
    ["DemoCompanyA", "四川省", "成都市"], ["DemoCompanyB", "四川省", "德阳市"]])
write_seed("company_group_mapping", "company_name,company_group_name", [
    ["DemoCompanyA", "DemoGroup"], ["DemoCompanyB", "DemoGroup"]])
write_seed("education_level_mapping", "raw_value,standardized_value", [["本科", "本科"], ["高中", "高中"]])
write_seed("training_type_mapping", "raw_value,standardized_value", [[stage, stage] for stage in ["新训", "复训", "换证"]])

sources = ["hazardous_chemical_management", "occupational_health", "safety_training_online", "safety_training_offline", "special_equipment", "special_operation"]
coordinators = [[source, "DemoCoordinator01", "DemoCoordinator01", "", "Confirmed"] for source in sources]
coordinators.append(["occupational_health", "DemoCancelled", "DemoCoordinator01", "取消", "Confirmed"])
write_seed("coordinator_name_mapping", "training_source,raw_coordinator_value,coordinator_name,salesperson_note,review_decision", coordinators)

# These rows demonstrate the schema. They are not real regulatory or price advice.
projects = [
    [1, sources[0], "安全管理人员", "危化品（经营单位）", "N/A", "N/A", "N/A", "N/A", "应急局"],
    [2, sources[1], "职业卫生", "N/A", "N/A", "N/A", "N/A", "N/A", "职业健康协会"],
    [3, sources[2], "其他从业人员", "N/A", "N/A", "N/A", "其他", "N/A", "应急局"],
    [4, sources[3], "其他从业人员", "N/A", "N/A", "N/A", "有限空间", "N/A", "应急局"],
    [5, sources[4], "特种设备", "N/A", "N/A", "N/A", "N/A", "N1", "质监局"],
    [6, sources[5], "特种作业", "N/A", "电工作业", "低压电工作业", "N/A", "N/A", "应急局"],
]
write_seed("registration_project_mapping", "mapping_id,training_source,certificate_name,industry,project,subproject,training_category,project_code,classification_version,effective_start_date,effective_end_date,is_current,supervisory_authority",
    [row[:8] + ["demo-v1", "1900-01-01", "2099-12-31", "Y", row[8]] for row in projects])

price_rows, training_rows = [], []
stages = [("新训", 1), ("复训", 0.8), ("换证", 0.9)]
base_prices = {1: 800, 2: 500, 3: 400, 4: 600, 5: 1000, 6: 900}
for row in projects:
    key, _, certificate, industry, project, subproject, category, _, _ = row
    for stage, multiplier in stages:
        training_rows.append([len(training_rows) + 1, certificate, industry, project, subproject, category, stage, "是", "演示培训", "1900-01-01", "2099-12-31", "Y"])
        for fee in ["培训费", "理论考试费", "实操考试费"]:
            amount = int(base_prices[key] * multiplier) if fee == "培训费" else ("N/A" if certificate == "特种设备" else 100)
            price_rows.append([len(price_rows) + 1, key, certificate, industry, project, subproject, category, stage, fee, amount, "1900-01-01", "2099-12-31"])
write_seed("price_mapping", "price_key,registration_project_key,certificate_name,industry,project,subproject,training_type,training_stage,fee_category,market_price,effective_start_date,effective_end_date", price_rows)
write_seed("training_policy_mapping", "training_policy_key,certificate_name,industry,project,subproject,training_type,training_stage,training_required,training_format,effective_start_date,effective_end_date,is_current", training_rows)

policies = [("安全管理人员", "危化品", 36, "应急局"), ("职业卫生", "N/A", 36, "职业健康协会"),
    ("其他从业人员", "N/A", 36, "应急局"), ("有限空间", "N/A", 36, "应急局"),
    ("特种设备", "N/A", 48, "质监局"), ("特种作业", "N/A", 72, "应急局")]
write_seed("certificate_update_policy_mapping", "certificate_update_policy_key,certificate_name,certificate_number_rule,industry,review_cycle_months,review_record_format,certificate_update_cycle_months,replacement_cycle_months,replaces_physical_certificate,certificate_number_changes,advance_reminder_days,supervisory_authority,effective_start_date,effective_end_date,is_current",
    [[i, certificate, "演示规则", industry, "N/A", "演示记录", months, months, "否", "否", 90, authority, "1900-01-01", "2099-12-31", "Y"]
     for i, (certificate, industry, months, authority) in enumerate(policies, 1)])

print("Generated 10 synthetic mapping seeds (no production records read).")
